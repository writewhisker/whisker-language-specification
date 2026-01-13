#!/usr/bin/env lua
-- WLS Validation Parity Test
-- Tests that Lua validators produce the same results as TypeScript validators
--
-- Usage: lua validation-parity-test.lua

package.path = "/Users/jims/code/github.com/writewhisker/whisker-core/lib/?.lua;" ..
               "/Users/jims/code/github.com/writewhisker/whisker-core/lib/?/init.lua;" ..
               package.path

local validators = require("whisker.validators")

-- Test cases with expected validation results
local TEST_CASES = {
  -- WLS-STR-001: Missing start passage
  {
    name = "missing_start_passage",
    story = {
      start_passage = nil,
      passages = {
        notstart = { title = "NotStart", content = "Hello", choices = {} }
      }
    },
    expected = {
      errors = { "WLS-STR-001" },
      warnings = {},
      info = { "WLS-FLW-001" },  -- no choices = dead end
    }
  },

  -- WLS-STR-002: Unreachable passage
  {
    name = "unreachable_passage",
    story = {
      start_passage = "start",
      passages = {
        start = { title = "Start", content = "Hello", choices = {} },
        orphan = { title = "Orphan", content = "Unreachable", choices = {} }
      }
    },
    expected = {
      errors = {},
      warnings = { "WLS-STR-002" },
      info = { "WLS-FLW-001", "WLS-FLW-001" },  -- both have no choices
    }
  },

  -- WLS-STR-003: Duplicate passage names
  {
    name = "duplicate_passages",
    story = {
      start_passage = "start1",
      passages = {
        start1 = { title = "Start", content = "First", choices = {} },
        start2 = { title = "Start", content = "Second", choices = {} }
      }
    },
    expected = {
      errors = { "WLS-STR-003", "WLS-STR-003" },
      warnings = { "WLS-STR-002" },  -- start2 is unreachable
      info = { "WLS-FLW-001", "WLS-FLW-001" },  -- both have no choices
    }
  },

  -- WLS-STR-004: Empty passage
  {
    name = "empty_passage",
    story = {
      start_passage = "start",
      passages = {
        start = { title = "Start", content = "", choices = {
          { text = "Go", target = "end" }
        }},
        ["end"] = { title = "End", content = "Done", choices = {} }
      }
    },
    expected = {
      errors = {},
      warnings = { "WLS-STR-004" },
      info = { "WLS-FLW-001" },  -- end has no choices
    }
  },

  -- WLS-LNK-001: Dead link
  {
    name = "dead_link",
    story = {
      start_passage = "start",
      passages = {
        start = { title = "Start", content = "Hello", choices = {
          { text = "Go", target = "nonexistent" }
        }}
      }
    },
    expected = {
      errors = { "WLS-LNK-001" },
      warnings = {},
    }
  },

  -- WLS-LNK-002: Self-link without action
  {
    name = "self_link_no_action",
    story = {
      start_passage = "start",
      passages = {
        start = { title = "Start", content = "Loop", choices = {
          { text = "Stay", target = "start" }
        }}
      }
    },
    expected = {
      errors = {},
      warnings = { "WLS-LNK-002" },
    }
  },

  -- WLS-LNK-002: Self-link with action (should pass)
  {
    name = "self_link_with_action",
    story = {
      start_passage = "start",
      passages = {
        start = { title = "Start", content = "Counter", choices = {
          { text = "Increment", target = "start", action = "count = count + 1" }
        }}
      },
      variables = { count = { name = "count", type = "number", initial = 0 } }
    },
    expected = {
      errors = {},
      warnings = {},
    }
  },

  -- WLS-LNK-003: Special target wrong case
  {
    name = "special_target_wrong_case",
    story = {
      start_passage = "start",
      passages = {
        start = { title = "Start", content = "Hello", choices = {
          { text = "End", target = "end" }
        }}
      }
    },
    expected = {
      errors = {},
      warnings = { "WLS-LNK-003" },
    }
  },

  -- WLS-LNK-005: Empty choice target
  {
    name = "empty_choice_target",
    story = {
      start_passage = "start",
      passages = {
        start = { title = "Start", content = "Hello", choices = {
          { text = "Go", target = "" }
        }}
      }
    },
    expected = {
      errors = { "WLS-LNK-005" },
      warnings = {},
    }
  },

  -- WLS-VAR-002: Unused variable
  {
    name = "unused_variable",
    story = {
      start_passage = "start",
      passages = {
        start = { title = "Start", content = "Hello", choices = {} }
      },
      variables = { unused = { name = "unused", type = "number", initial = 0 } }
    },
    expected = {
      errors = {},
      warnings = { "WLS-VAR-002" },
      info = { "WLS-FLW-001" },  -- no choices
    }
  },

  -- Clean story (no issues)
  {
    name = "clean_story",
    story = {
      start_passage = "start",
      passages = {
        start = { title = "Start", content = "Hello", choices = {
          { text = "Continue", target = "end" }
        }},
        ["end"] = { title = "End", content = "Done", choices = {
          { text = "Restart", target = "RESTART" }
        }}
      }
    },
    expected = {
      errors = {},
      warnings = {},
      info = {},
    }
  },

  -- WLS-FLW-001: Dead end (no choices)
  {
    name = "dead_end",
    story = {
      start_passage = "start",
      passages = {
        start = { title = "Start", content = "Beginning", choices = {
          { text = "Continue", target = "ending" }
        }},
        ending = { title = "The End", content = "Story over.", choices = {} }
      }
    },
    expected = {
      errors = {},
      warnings = {},
      info = { "WLS-FLW-001" },
    }
  },

  -- WLS-FLW-001: Multiple dead ends
  {
    name = "multiple_dead_ends",
    story = {
      start_passage = "start",
      passages = {
        start = { title = "Start", content = "Choose", choices = {
          { text = "Good", target = "good" },
          { text = "Bad", target = "bad" }
        }},
        good = { title = "Good End", content = "You won!", choices = {} },
        bad = { title = "Bad End", content = "You lost.", choices = {} }
      }
    },
    expected = {
      errors = {},
      warnings = {},
      info = { "WLS-FLW-001", "WLS-FLW-001" },
    }
  },
}

-- Helper to extract error codes from issues
local function extract_codes(issues, severity)
  local codes = {}
  for _, issue in ipairs(issues) do
    if issue.severity == severity then
      table.insert(codes, issue.code)
    end
  end
  table.sort(codes)
  return codes
end

-- Helper to compare arrays
local function arrays_equal(a, b)
  if #a ~= #b then return false end
  for i, v in ipairs(a) do
    if v ~= b[i] then return false end
  end
  return true
end

-- Run tests
local function run_tests()
  print("WLS Validation Parity Test")
  print("==============================")
  print("")

  local passed = 0
  local failed = 0
  local results = {}

  for _, test in ipairs(TEST_CASES) do
    local result = validators.validate(test.story)
    local actual_errors = extract_codes(result.issues, "error")
    local actual_warnings = extract_codes(result.issues, "warning")
    local actual_info = extract_codes(result.issues, "info")

    local expected_errors = test.expected.errors or {}
    local expected_warnings = test.expected.warnings or {}
    local expected_info = test.expected.info or {}
    table.sort(expected_errors)
    table.sort(expected_warnings)
    table.sort(expected_info)

    local errors_match = arrays_equal(actual_errors, expected_errors)
    local warnings_match = arrays_equal(actual_warnings, expected_warnings)
    local info_match = arrays_equal(actual_info, expected_info)
    local test_passed = errors_match and warnings_match and info_match

    if test_passed then
      passed = passed + 1
      print(string.format("  ✓ %s", test.name))
    else
      failed = failed + 1
      print(string.format("  ✗ %s", test.name))
      if not errors_match then
        print(string.format("      Expected errors: %s", table.concat(expected_errors, ", ")))
        print(string.format("      Actual errors:   %s", table.concat(actual_errors, ", ")))
      end
      if not warnings_match then
        print(string.format("      Expected warnings: %s", table.concat(expected_warnings, ", ")))
        print(string.format("      Actual warnings:   %s", table.concat(actual_warnings, ", ")))
      end
      if not info_match then
        print(string.format("      Expected info: %s", table.concat(expected_info, ", ")))
        print(string.format("      Actual info:   %s", table.concat(actual_info, ", ")))
      end
    end

    table.insert(results, {
      name = test.name,
      passed = test_passed,
      expected_errors = expected_errors,
      actual_errors = actual_errors,
      expected_warnings = expected_warnings,
      actual_warnings = actual_warnings,
    })
  end

  print("")
  print("==============================")
  print(string.format("Results: %d/%d passed", passed, #TEST_CASES))
  if failed == 0 then
    print("All tests passed! Lua validators match expected behavior.")
  else
    print(string.format("%d tests failed.", failed))
  end
  print("")

  return passed, failed, results
end

-- Run
local passed, failed = run_tests()
os.exit(failed > 0 and 1 or 0)
