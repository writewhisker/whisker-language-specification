#!/usr/bin/env lua
-- WLS Validation Corpus Runner for whisker-core
-- Runs validation test corpus against Lua validators
--
-- Usage: lua validation-corpus-runner.lua [corpus_path] [output_file] [whisker_core_path]
-- Environment: WHISKER_CORE_PATH can be set to override default whisker-core location

-- Configure whisker-core path (from environment, arg, or default relative path)
local WHISKER_CORE_PATH = os.getenv("WHISKER_CORE_PATH") or
                          arg[3] or
                          "/Users/jims/code/github.com/writewhisker/whisker-core/lib"

package.path = WHISKER_CORE_PATH .. "/?.lua;" ..
               WHISKER_CORE_PATH .. "/?/init.lua;" ..
               package.path

-- Load required modules with helpful error messages
local function safe_require(name, hint)
    local ok, mod = pcall(require, name)
    if not ok then
        io.stderr:write(string.format("Error: Could not load module '%s'\n", name))
        if hint then
            io.stderr:write(string.format("Hint: %s\n", hint))
        end
        io.stderr:write(string.format("Details: %s\n", tostring(mod)))
        os.exit(1)
    end
    return mod
end

local yaml = safe_require("lyaml", "Install via: luarocks install lyaml")
local json = safe_require("cjson", "Install via: luarocks install lua-cjson")
local WSParser = safe_require("whisker.parser.ws_parser",
    "Set WHISKER_CORE_PATH environment variable to whisker-core/lib directory")
local validators = safe_require("whisker.validators",
    "Set WHISKER_CORE_PATH environment variable to whisker-core/lib directory")

-- Default paths (use absolute paths for reliability)
local SCRIPT_DIR = debug.getinfo(1, "S").source:match("@?(.*/)")
local CORPUS_PATH = arg[1] or (SCRIPT_DIR .. "../test-corpus/validation")
local OUTPUT_FILE = arg[2] or (SCRIPT_DIR .. "../test-results/validation-lua-results.json")

-- Validation test files
local TEST_FILES = {
    "structural-tests.yaml",
    "links-tests.yaml",
    "variables-tests.yaml",
    "flow-tests.yaml",
    "combined-tests.yaml"
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

-- Extract error codes from validation issues by severity
local function extract_codes(issues, severity)
    local codes = {}
    for _, issue in ipairs(issues or {}) do
        if issue.severity == severity then
            table.insert(codes, issue.code)
        end
    end
    table.sort(codes)
    return codes
end

-- Compare two sorted arrays
local function arrays_equal(a, b)
    if #a ~= #b then return false end
    for i, v in ipairs(a) do
        if v ~= b[i] then return false end
    end
    return true
end

-- Convert parser story to validator-compatible format
local function convert_story(parse_result)
    if not parse_result.success or not parse_result.story then
        return nil
    end

    local story = parse_result.story
    local converted = {
        start_passage = story.start_passage or story.startPassage,
        passages = {},
        variables = {},
        duplicate_passages = story.duplicate_passages or {}
    }

    -- Convert variables (handle both raw {name, value, type} format and simple value format)
    if story.variables then
        for name, var_data in pairs(story.variables) do
            if type(var_data) == "table" then
                -- Keep invalid flag if present
                converted.variables[name] = {
                    value = var_data.value,
                    invalid = var_data.invalid
                }
            else
                converted.variables[name] = { value = var_data }
            end
        end
    end

    -- Build name-to-ID mapping for resolving choice targets
    local name_to_id = {}
    for id, passage in pairs(story.passages or {}) do
        local name = passage.name or passage.title or id
        if not name_to_id[name] then
            name_to_id[name] = id
        end
    end

    -- Convert passages
    for id, passage in pairs(story.passages or {}) do
        converted.passages[id] = {
            title = passage.title or passage.name or id,
            content = passage.content or passage.body or "",
            choices = {}
        }

        -- Convert choices, resolving target names to IDs
        for _, choice in ipairs(passage.choices or {}) do
            local target_name = choice.target or choice.targetPassage or ""
            local target_id = target_name

            -- Resolve name to ID if it's not a special target and exists in mapping
            if target_name ~= "" and target_name ~= "END" and target_name ~= "BACK" and target_name ~= "RESTART" then
                if name_to_id[target_name] then
                    target_id = name_to_id[target_name]
                end
            end

            table.insert(converted.passages[id].choices, {
                text = choice.text or "",
                target = target_id,
                condition = choice.condition,
                action = choice.action
            })
        end
    end

    -- start_passage should already be resolved to ID by the parser
    -- But check if not set and look for "Start" passage
    if not converted.start_passage then
        for id, passage in pairs(converted.passages) do
            if (passage.title or ""):lower() == "start" then
                converted.start_passage = id
                break
            end
        end
    end

    return converted
end

-- Run a single validation test
local function run_test(test)
    local start_time = os.clock()
    local result = {
        name = test.name,
        description = test.description,
        passed = false,
        expected = {
            errors = {},
            warnings = {},
            info = {}
        },
        actual = {
            errors = {},
            warnings = {},
            info = {}
        },
        parse_valid = false,
        duration = 0
    }

    -- Extract expected validation codes
    local validation = test.validation or {}
    for _, err in ipairs(validation.errors or {}) do
        if type(err) == "table" then
            table.insert(result.expected.errors, err.code)
        elseif type(err) == "string" then
            table.insert(result.expected.errors, err)
        end
    end
    for _, warn in ipairs(validation.warnings or {}) do
        if type(warn) == "table" then
            table.insert(result.expected.warnings, warn.code)
        elseif type(warn) == "string" then
            table.insert(result.expected.warnings, warn)
        end
    end
    for _, inf in ipairs(validation.info or {}) do
        if type(inf) == "table" then
            table.insert(result.expected.info, inf.code)
        elseif type(inf) == "string" then
            table.insert(result.expected.info, inf)
        end
    end
    table.sort(result.expected.errors)
    table.sort(result.expected.warnings)
    table.sort(result.expected.info)

    -- Parse the Whisker source
    local ok, err = pcall(function()
        local parser = WSParser.new()
        local parse_result = parser:parse(test.input or "")

        result.parse_valid = parse_result.success

        -- Validate if story is present, even with non-critical parse errors
        -- The parser may report warnings but still produce a valid story
        if parse_result.story then
            -- Convert to validator format and run validation
            local story = convert_story(parse_result)
            if story then
                local validation_result = validators.validate(story)

                result.actual.errors = extract_codes(validation_result.issues, "error")
                result.actual.warnings = extract_codes(validation_result.issues, "warning")
                result.actual.info = extract_codes(validation_result.issues, "info")
            end
        end
    end)

    if not ok then
        result.error = tostring(err)
    end

    result.duration = (os.clock() - start_time) * 1000

    -- Check if test passed
    local errors_match = arrays_equal(result.actual.errors, result.expected.errors)
    local warnings_match = arrays_equal(result.actual.warnings, result.expected.warnings)
    local info_match = arrays_equal(result.actual.info, result.expected.info)

    result.passed = errors_match and warnings_match and info_match
    result.errors_match = errors_match
    result.warnings_match = warnings_match
    result.info_match = info_match

    return result
end

-- Main runner
local function main()
    print("WLS Validation Corpus Runner for whisker-core")
    print("================================================")
    print("Loading validation tests from: " .. CORPUS_PATH)
    print("")

    local results = {
        platform = "whisker-core",
        type = "validation",
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        files = {},
        summary = {
            total = 0,
            passed = 0,
            failed = 0,
            passRate = "0%"
        }
    }

    local total_tests = 0
    local total_passed = 0

    for _, filename in ipairs(TEST_FILES) do
        local filepath = CORPUS_PATH .. "/" .. filename
        local data = load_yaml(filepath)

        if data and data.tests then
            local file_results = {
                filename = filename,
                total = #data.tests,
                passed = 0,
                failed = 0,
                tests = {}
            }

            print(string.format("  Running %s (%d tests)...", filename, #data.tests))

            for _, test in ipairs(data.tests) do
                local result = run_test(test)
                table.insert(file_results.tests, result)
                if result.passed then
                    file_results.passed = file_results.passed + 1
                else
                    -- Print failure details
                    print(string.format("    ✗ %s", result.name))
                    if not result.errors_match then
                        print(string.format("      Expected errors: %s", table.concat(result.expected.errors, ", ")))
                        print(string.format("      Actual errors:   %s", table.concat(result.actual.errors, ", ")))
                    end
                    if not result.warnings_match then
                        print(string.format("      Expected warnings: %s", table.concat(result.expected.warnings, ", ")))
                        print(string.format("      Actual warnings:   %s", table.concat(result.actual.warnings, ", ")))
                    end
                    if not result.info_match then
                        print(string.format("      Expected info: %s", table.concat(result.expected.info, ", ")))
                        print(string.format("      Actual info:   %s", table.concat(result.actual.info, ", ")))
                    end
                end
            end

            file_results.failed = file_results.total - file_results.passed
            table.insert(results.files, file_results)

            total_tests = total_tests + file_results.total
            total_passed = total_passed + file_results.passed

            local status = file_results.failed == 0 and "✓" or "✗"
            print(string.format("    %s %d/%d passed", status, file_results.passed, file_results.total))
        else
            print(string.format("  Warning: Could not load %s", filepath))
        end
    end

    results.summary.total = total_tests
    results.summary.passed = total_passed
    results.summary.failed = total_tests - total_passed
    if total_tests > 0 then
        results.summary.passRate = string.format("%.1f%%", (total_passed / total_tests) * 100)
    end

    -- Print summary
    print("")
    print("================================================")
    print("Summary")
    print("================================================")
    print(string.format("  Total:     %d", total_tests))
    print(string.format("  Passed:    %d", total_passed))
    print(string.format("  Failed:    %d", total_tests - total_passed))
    print(string.format("  Pass Rate: %s", results.summary.passRate))
    print("")

    -- Save results
    local file = io.open(OUTPUT_FILE, "w")
    if file then
        file:write(json.encode(results))
        file:close()
        print("Results saved to: " .. OUTPUT_FILE)
    else
        print("Warning: Could not save results to " .. OUTPUT_FILE)
    end

    return total_tests - total_passed == 0
end

-- Run and exit with appropriate code
local success = main()
os.exit(success and 0 or 1)
