#!/usr/bin/env lua
-- WLS Test Corpus Runner for whisker-core
-- Runs test corpus against the whisker-core WLS parser
--
-- Usage: lua whisker-core-runner.lua [corpus_path] [output_file]

package.path = "/Users/jims/code/github.com/writewhisker/whisker-core/lib/?.lua;" ..
               "/Users/jims/code/github.com/writewhisker/whisker-core/lib/?/init.lua;" ..
               package.path

local yaml = require("lyaml") -- Need to install: luarocks install lyaml
local json = require("cjson") -- Need to install: luarocks install lua-cjson
local WSParser = require("whisker.parser.ws_parser")

-- Default paths
local CORPUS_PATH = arg[1] or "../test-corpus"
local OUTPUT_FILE = arg[2] or "../test-results/whisker-core-results.json"

-- Test categories
local CATEGORIES = {
    "syntax",
    "variables",
    "conditionals",
    "choices",
    "alternatives",
    "api",
    "formats",
    "edge-cases"
}

-- Load YAML file
local function load_yaml(filepath)
    local file = io.open(filepath, "r")
    if not file then
        return nil, "Could not open file: " .. filepath
    end
    local content = file:read("*all")
    file:close()

    local ok, result = pcall(yaml.load, content)
    if not ok then
        return nil, "YAML parse error: " .. tostring(result)
    end
    return result
end

-- Timeout mechanism using debug hook
local MAX_INSTRUCTIONS = 1000000  -- Max instructions before timeout

local function run_with_timeout(func)
    local instruction_count = 0
    local timed_out = false

    local function hook()
        instruction_count = instruction_count + 1
        if instruction_count > MAX_INSTRUCTIONS then
            timed_out = true
            error("TIMEOUT: Parser exceeded instruction limit")
        end
    end

    debug.sethook(hook, "", 10000)  -- Call hook every 10000 instructions
    local ok, result = pcall(func)
    debug.sethook()  -- Remove hook

    return ok, result, timed_out
end

-- Run a single test
local function run_test(test)
    local start_time = os.clock()
    local result = {
        name = test.name,
        passed = false,
        expected = test.expected or {},
        actual = {},
        duration = 0
    }

    local ok, err, timed_out = run_with_timeout(function()
        -- Parse directly (parser handles tokenization internally)
        local parser = WSParser.new()
        local parse_result = parser:parse(test.input or "")

        result.actual.valid = parse_result.success
        if parse_result.story then
            result.actual.passages = 0
            for _ in pairs(parse_result.story.passages or {}) do
                result.actual.passages = result.actual.passages + 1
            end
        end

        if not parse_result.success and parse_result.errors and #parse_result.errors > 0 then
            result.actual.error = parse_result.errors[1].message
        end
        return result.actual
    end)

    if not ok then
        result.actual.valid = false
        result.actual.error = tostring(err)
    end

    result.duration = (os.clock() - start_time) * 1000 -- Convert to ms

    -- Check if test passed
    local expected = test.expected or {}
    result.passed = true

    if expected.passages ~= nil then
        if result.actual.passages ~= expected.passages then
            result.passed = false
        end
    end

    if expected.valid ~= nil then
        if result.actual.valid ~= expected.valid then
            result.passed = false
        end
    end

    if expected.error ~= nil and expected.error ~= "" then
        if result.actual.valid == true then
            result.passed = false
        end
    end

    return result
end

-- Load all tests from a category
local function load_category(category)
    local tests = {}
    local category_path = CORPUS_PATH .. "/" .. category

    -- Get list of YAML files
    local handle = io.popen('ls "' .. category_path .. '"/*.yaml 2>/dev/null || ls "' .. category_path .. '"/*.yml 2>/dev/null')
    if not handle then
        return tests
    end

    for filepath in handle:lines() do
        local data = load_yaml(filepath)
        if data and data.tests then
            for _, test in ipairs(data.tests) do
                table.insert(tests, test)
            end
        end
    end
    handle:close()

    return tests
end

-- Main runner
local function main()
    print("WLS Test Corpus Runner for whisker-core")
    print("Loading test corpus from: " .. CORPUS_PATH)
    print("")

    local results = {
        platform = "whisker-core",
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        categories = {},
        summary = {
            total = 0,
            passed = 0,
            failed = 0,
            passRate = "0%"
        }
    }

    local total_tests = 0
    local total_passed = 0

    for _, category in ipairs(CATEGORIES) do
        local tests = load_category(category)
        local category_results = {
            category = category,
            total = #tests,
            passed = 0,
            failed = 0,
            tests = {}
        }

        print(string.format("  Running %s (%d tests)...", category, #tests))

        for _, test in ipairs(tests) do
            local result = run_test(test)
            table.insert(category_results.tests, result)
            if result.passed then
                category_results.passed = category_results.passed + 1
            end
        end

        category_results.failed = category_results.total - category_results.passed
        table.insert(results.categories, category_results)

        total_tests = total_tests + category_results.total
        total_passed = total_passed + category_results.passed
    end

    results.summary.total = total_tests
    results.summary.passed = total_passed
    results.summary.failed = total_tests - total_passed
    results.summary.passRate = string.format("%.1f%%", (total_passed / total_tests) * 100)

    -- Print summary
    print("")
    print(string.format("  %d/%d passed (%s)", total_passed, total_tests, results.summary.passRate))
    print("")
    print("============================================================")
    print("WLS Test Corpus Results - whisker-core")
    print("============================================================")
    print(string.format("  Total: %d", total_tests))
    print(string.format("  Passed: %d", total_passed))
    print(string.format("  Failed: %d", total_tests - total_passed))
    print(string.format("  Pass Rate: %s", results.summary.passRate))
    print("")
    print("  By Category:")
    for _, cat in ipairs(results.categories) do
        local status = cat.failed == 0 and "✓" or "✗"
        print(string.format("    %s %s: %d/%d", status, cat.category, cat.passed, cat.total))
    end
    print("============================================================")

    -- Save results
    local file = io.open(OUTPUT_FILE, "w")
    if file then
        file:write(json.encode(results))
        file:close()
        print("")
        print("Results saved to: " .. OUTPUT_FILE)
    else
        print("Warning: Could not save results to " .. OUTPUT_FILE)
    end

    return results
end

-- Run main
main()
