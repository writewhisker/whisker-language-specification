#!/usr/bin/env node
/**
 * WLS Validation Corpus Runner for whisker-editor-web
 * Runs validation test corpus against TypeScript validators
 *
 * Usage: node validation-corpus-runner.cjs [corpus_path] [output_file]
 */

const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');

// Paths
const CORPUS_PATH = process.argv[2] || path.join(__dirname, '../test-corpus/validation');
const OUTPUT_FILE = process.argv[3] || path.join(__dirname, '../test-results/validation-ts-results.json');

// Test files
const TEST_FILES = [
  'structural-tests.yaml',
  'links-tests.yaml',
  'variables-tests.yaml',
  'flow-tests.yaml',
  'combined-tests.yaml'
];

// Load parser and validators
let parse, StoryValidator, createDefaultValidator, Story;

async function loadModules() {
  try {
    const parserPath = path.resolve(__dirname, '../../phase-3-whisker-editor-web/packages/parser/dist/index.js');
    const validationPath = path.resolve(__dirname, '../../phase-3-whisker-editor-web/packages/story-validation/dist/index.js');
    const modelsPath = path.resolve(__dirname, '../../phase-3-whisker-editor-web/packages/story-models/dist/index.js');

    const parserModule = require(parserPath);
    const validationModule = require(validationPath);
    const modelsModule = require(modelsPath);

    parse = parserModule.parse;
    StoryValidator = validationModule.StoryValidator;
    createDefaultValidator = validationModule.createDefaultValidator;
    Story = modelsModule.Story;

    return true;
  } catch (err) {
    // Try alternate path structure
    try {
      const parserPath = path.resolve(__dirname, '../../writewhisker/whisker-editor-web/packages/parser/dist/index.js');
      const validationPath = path.resolve(__dirname, '../../writewhisker/whisker-editor-web/packages/story-validation/dist/index.js');
      const modelsPath = path.resolve(__dirname, '../../writewhisker/whisker-editor-web/packages/story-models/dist/index.js');

      const parserModule = require(parserPath);
      const validationModule = require(validationPath);
      const modelsModule = require(modelsPath);

      parse = parserModule.parse;
      StoryValidator = validationModule.StoryValidator;
      createDefaultValidator = validationModule.createDefaultValidator;
      Story = modelsModule.Story;

      return true;
    } catch (err2) {
      console.error('Failed to load modules:', err2.message);
      console.error('Make sure packages are built: pnpm --filter @writewhisker/parser --filter @writewhisker/story-validation --filter @writewhisker/story-models build');
      return false;
    }
  }
}

// Extract error codes from validation issues by severity
function extractCodes(issues, severity) {
  return issues
    .filter(i => i.severity === severity)
    .map(i => i.code)
    .sort();
}

// Serialize an expression AST node to a string for validation
function serializeExpression(node) {
  if (!node) return '';
  switch (node.type) {
    case 'variable':
      return (node.scope === 'temp' ? '_' : '$') + node.name;
    case 'literal':
      return typeof node.value === 'string' ? `"${node.value}"` : String(node.value);
    case 'binary_expression':
    case 'binaryExpression':
      return `${serializeExpression(node.left)} ${node.operator} ${serializeExpression(node.right)}`;
    case 'unary_expression':
    case 'unaryExpression':
      return `${node.operator} ${serializeExpression(node.operand)}`;
    case 'assignment':
    case 'assignment_expression':
    case 'assignmentExpression':
      return `${serializeExpression(node.target)} = ${serializeExpression(node.value)}`;
    case 'identifier':
      // Bare identifiers in conditions/actions are treated as variables
      return node.name;
    default:
      // Fallback: try to extract any identifiers
      if (node.name) return node.name;
      if (node.value !== undefined) return String(node.value);
      return JSON.stringify(node);
  }
}

// Load YAML file
function loadYaml(filepath) {
  try {
    const content = fs.readFileSync(filepath, 'utf-8');
    return yaml.load(content);
  } catch (err) {
    return null;
  }
}

// Run a single validation test
function runTest(test) {
  const startTime = Date.now();
  const result = {
    name: test.name,
    description: test.description,
    passed: false,
    expected: {
      errors: [],
      warnings: [],
      info: []
    },
    actual: {
      errors: [],
      warnings: [],
      info: []
    },
    parse_valid: false,
    duration: 0
  };

  // Extract expected validation codes
  const validation = test.validation || {};
  (validation.errors || []).forEach(err => {
    result.expected.errors.push(typeof err === 'object' ? err.code : err);
  });
  (validation.warnings || []).forEach(warn => {
    result.expected.warnings.push(typeof warn === 'object' ? warn.code : warn);
  });
  (validation.info || []).forEach(inf => {
    result.expected.info.push(typeof inf === 'object' ? inf.code : inf);
  });
  result.expected.errors.sort();
  result.expected.warnings.sort();
  result.expected.info.sort();

  try {
    // Parse the Whisker source
    const parseResult = parse(test.input || '');
    result.parse_valid = parseResult.errors.length === 0;

    // Validate if AST is present, even with non-critical parse errors
    // The parser may report spurious errors but still produce valid AST
    if (parseResult.ast && parseResult.ast.passages) {
      // Convert AST to Story model
      const storyData = {
        startPassage: '',
        passages: {},
        variables: {}
      };

      // Check for @start directive first
      if (parseResult.ast.metadata && Array.isArray(parseResult.ast.metadata)) {
        for (const meta of parseResult.ast.metadata) {
          if (meta.key === 'start' && meta.value) {
            // Find passage by title
            for (const passage of parseResult.ast.passages) {
              if (passage.name === meta.value) {
                storyData.startPassage = passage.id || passage.name;
                break;
              }
            }
            break;
          }
        }
      }

      // If no @start directive, find passage named "Start"
      if (!storyData.startPassage) {
        for (const passage of parseResult.ast.passages) {
          if (passage.name === 'Start') {
            storyData.startPassage = passage.id || passage.name;
            break;
          }
        }
      }

      // If still no start, leave it empty - the validator should detect WLS-STR-001
      // Do NOT fall back to first passage as that would mask the missing start error

      // Build passages object (Story expects Object, not Map)
      // Two-pass approach: first build passages and name->ID map, then resolve targets

      // First pass: build passages with unique IDs and create name->ID mapping
      let passageIndex = 0;
      const passageNameToId = new Map(); // Map passage name to first ID with that name
      const rawPassages = [];

      for (const passage of parseResult.ast.passages) {
        // Generate unique ID to avoid overwriting duplicates
        const id = passage.id || `passage_${passageIndex++}_${passage.name}`;

        // Only map the first occurrence of each name
        if (!passageNameToId.has(passage.name)) {
          passageNameToId.set(passage.name, id);
        }

        // Extract text content, choices, and do blocks from the content array
        let textContent = '';
        const rawChoices = [];
        let onEnterScript = '';

        if (Array.isArray(passage.content)) {
          for (const node of passage.content) {
            if (node.type === 'text') {
              textContent += node.value || '';
            } else if (node.type === 'interpolation') {
              // Preserve $variable syntax for validation
              if (node.expression && node.expression.type === 'variable') {
                textContent += '$' + node.expression.name;
              }
            } else if (node.type === 'do_block') {
              // Convert do_block actions to onEnterScript string for validation
              if (node.actions && Array.isArray(node.actions)) {
                const actionStr = node.actions.map(a => serializeExpression(a)).join('; ');
                if (onEnterScript) {
                  onEnterScript += '; ' + actionStr;
                } else {
                  onEnterScript = actionStr;
                }
              }
            } else if (node.type === 'choice') {
              const choiceText = Array.isArray(node.text)
                ? node.text.map(t => t.value || '').join('')
                : (node.text || '');
              // Convert condition/action AST to string for validation
              let conditionStr = null;
              let actionStr = null;
              if (node.condition) {
                conditionStr = serializeExpression(node.condition);
              }
              if (node.action && Array.isArray(node.action)) {
                actionStr = node.action.map(a => serializeExpression(a)).join('; ');
              }
              rawChoices.push({
                text: choiceText,
                targetName: node.target || '', // Keep original target name
                condition: conditionStr,
                action: actionStr
              });
            }
          }
        } else {
          textContent = passage.content || '';
        }

        rawPassages.push({
          id,
          title: passage.name,
          content: textContent.trim(),
          rawChoices,
          onEnterScript: onEnterScript || null
        });
      }

      // Second pass: resolve choice targets from names to IDs
      for (const passage of rawPassages) {
        const choices = passage.rawChoices.map((choice, i) => {
          // Resolve target name to ID
          let targetId = choice.targetName;
          if (targetId && passageNameToId.has(targetId)) {
            targetId = passageNameToId.get(targetId);
          }
          // Empty string targets stay empty (for END/dead ends)
          return {
            id: `${passage.id}_choice_${i}`,
            text: choice.text,
            target: targetId,
            condition: choice.condition,
            action: choice.action
          };
        });

        storyData.passages[passage.id] = {
          id: passage.id,
          title: passage.title,
          content: passage.content,
          choices,
          onEnterScript: passage.onEnterScript
        };
      }

      // Update startPassage to use the mapped ID
      if (storyData.startPassage && passageNameToId.has(storyData.startPassage)) {
        storyData.startPassage = passageNameToId.get(storyData.startPassage);
      }

      // Build variables from @vars block
      if (parseResult.ast.variables && Array.isArray(parseResult.ast.variables)) {
        for (const varDecl of parseResult.ast.variables) {
          const value = varDecl.initialValue?.value !== undefined
            ? varDecl.initialValue.value
            : varDecl.value;
          storyData.variables[varDecl.name] = {
            name: varDecl.name,
            type: typeof value === 'boolean' ? 'boolean' : typeof value === 'number' ? 'number' : 'string',
            initial: value,
            scope: varDecl.scope || 'story'
          };
        }
      }

      // Also parse @var: directives from metadata
      if (parseResult.ast.metadata && Array.isArray(parseResult.ast.metadata)) {
        for (const meta of parseResult.ast.metadata) {
          if (meta.key === 'var' && meta.value) {
            // Parse "name = value" or "name=value"
            // Allow invalid names too (like 1stVar) so validator can detect them
            const match = meta.value.match(/^\s*([a-zA-Z0-9_]+)\s*=\s*(.+)$/);
            if (match) {
              const varName = match[1];
              let varValue = match[2].trim();
              let varType = 'string';
              // Parse value type
              if (varValue === 'true') { varValue = true; varType = 'boolean'; }
              else if (varValue === 'false') { varValue = false; varType = 'boolean'; }
              else if (/^-?\d+$/.test(varValue)) { varValue = parseInt(varValue, 10); varType = 'number'; }
              else if (/^-?\d+\.\d+$/.test(varValue)) { varValue = parseFloat(varValue); varType = 'number'; }
              else if (/^["'].*["']$/.test(varValue)) varValue = varValue.slice(1, -1);

              storyData.variables[varName] = {
                name: varName,
                type: varType,
                initial: varValue,
                scope: 'story'
              };
            }
          }
        }
      }

      // Create Story and validate
      const story = new Story(storyData);
      const validator = createDefaultValidator();
      const validationResult = validator.validate(story);

      result.actual.errors = extractCodes(validationResult.issues, 'error');
      result.actual.warnings = extractCodes(validationResult.issues, 'warning');
      result.actual.info = extractCodes(validationResult.issues, 'info');
    }
  } catch (err) {
    result.error = err.message;
  }

  result.duration = Date.now() - startTime;

  // Check if test passed
  const arraysEqual = (a, b) => {
    if (a.length !== b.length) return false;
    for (let i = 0; i < a.length; i++) {
      if (a[i] !== b[i]) return false;
    }
    return true;
  };

  result.errors_match = arraysEqual(result.actual.errors, result.expected.errors);
  result.warnings_match = arraysEqual(result.actual.warnings, result.expected.warnings);
  result.info_match = arraysEqual(result.actual.info, result.expected.info);
  result.passed = result.errors_match && result.warnings_match && result.info_match;

  return result;
}

// Main runner
async function main() {
  console.log('WLS Validation Corpus Runner for whisker-editor-web');
  console.log('========================================================');

  if (!await loadModules()) {
    process.exit(1);
  }

  console.log('Loading validation tests from:', CORPUS_PATH);
  console.log('');

  const results = {
    platform: 'whisker-editor-web',
    type: 'validation',
    timestamp: new Date().toISOString(),
    files: [],
    summary: {
      total: 0,
      passed: 0,
      failed: 0,
      passRate: '0%'
    }
  };

  let totalTests = 0;
  let totalPassed = 0;

  for (const filename of TEST_FILES) {
    const filepath = path.join(CORPUS_PATH, filename);
    const data = loadYaml(filepath);

    if (data && data.tests) {
      const fileResults = {
        filename,
        total: data.tests.length,
        passed: 0,
        failed: 0,
        tests: []
      };

      console.log(`  Running ${filename} (${data.tests.length} tests)...`);

      for (const test of data.tests) {
        const result = runTest(test);
        fileResults.tests.push(result);
        if (result.passed) {
          fileResults.passed++;
        } else {
          console.log(`    ✗ ${result.name}`);
          if (!result.errors_match) {
            console.log(`      Expected errors: ${result.expected.errors.join(', ') || '(none)'}`);
            console.log(`      Actual errors:   ${result.actual.errors.join(', ') || '(none)'}`);
          }
          if (!result.warnings_match) {
            console.log(`      Expected warnings: ${result.expected.warnings.join(', ') || '(none)'}`);
            console.log(`      Actual warnings:   ${result.actual.warnings.join(', ') || '(none)'}`);
          }
          if (!result.info_match) {
            console.log(`      Expected info: ${result.expected.info.join(', ') || '(none)'}`);
            console.log(`      Actual info:   ${result.actual.info.join(', ') || '(none)'}`);
          }
        }
      }

      fileResults.failed = fileResults.total - fileResults.passed;
      results.files.push(fileResults);

      totalTests += fileResults.total;
      totalPassed += fileResults.passed;

      const status = fileResults.failed === 0 ? '✓' : '✗';
      console.log(`    ${status} ${fileResults.passed}/${fileResults.total} passed`);
    } else {
      console.log(`  Warning: Could not load ${filepath}`);
    }
  }

  results.summary.total = totalTests;
  results.summary.passed = totalPassed;
  results.summary.failed = totalTests - totalPassed;
  if (totalTests > 0) {
    results.summary.passRate = `${((totalPassed / totalTests) * 100).toFixed(1)}%`;
  }

  // Print summary
  console.log('');
  console.log('========================================================');
  console.log('Summary');
  console.log('========================================================');
  console.log(`  Total:     ${totalTests}`);
  console.log(`  Passed:    ${totalPassed}`);
  console.log(`  Failed:    ${totalTests - totalPassed}`);
  console.log(`  Pass Rate: ${results.summary.passRate}`);
  console.log('');

  // Save results
  try {
    const outputDir = path.dirname(OUTPUT_FILE);
    if (!fs.existsSync(outputDir)) {
      fs.mkdirSync(outputDir, { recursive: true });
    }
    fs.writeFileSync(OUTPUT_FILE, JSON.stringify(results, null, 2));
    console.log('Results saved to:', OUTPUT_FILE);
  } catch (err) {
    console.log('Warning: Could not save results:', err.message);
  }

  process.exit(totalTests - totalPassed === 0 ? 0 : 1);
}

main().catch(console.error);
