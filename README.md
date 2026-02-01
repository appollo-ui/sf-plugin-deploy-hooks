# SF CLI Deploy Hooks Plugin

A Salesforce CLI plugin that executes configurable bash scripts before and after `sf project deploy` commands with AI-powered error analysis support.

[![npm version](https://badge.fury.io/js/%40appollo-ui%2Fsf-plugin-deploy-hooks.svg)](https://www.npmjs.com/package/@appollo-ui/sf-plugin-deploy-hooks)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features

- ✅ **Pre-deploy hooks** - Run validation, tests, or checks before deployment
- ✅ **Post-deploy hooks** - Execute cleanup, notifications, or analysis after deployment
- ✅ **Deploy result analysis** - Access full deployment results in JSON format
- ✅ **AI-powered error analysis** - Automatic error detection and fix suggestions with GitHub Copilot
- ✅ **Configurable** - Simple JSON configuration for multiple hooks
- ✅ **Non-blocking post-hooks** - Post-deploy failures won't affect your deployment
- ✅ **Environment variables** - Access command context in your scripts

## Installation

### Install from npm

```bash
sf plugins install @appollo-ui/sf-plugin-deploy-hooks
```

### Install from source (development)

```bash
git clone https://github.com/appollo-ui/sf-plugin-deploy-hooks.git
cd sf-plugin-deploy-hooks
npm install
npm run build
sf plugins link .
```

### Verify installation

```bash
sf plugins
```

You should see `@appollo-ui/sf-plugin-deploy-hooks` in the list.

## Configuration

Create a `.sfhooks.json` or `sf-hooks.json` file in your project root:

```json
{
  "hooks": {
    "preDeploy": [
      "./scripts/lint.sh",
      "./scripts/test.sh",
      "./scripts/pre-deploy-checks.sh"
    ],
    "postDeploy": [
      "./scripts/notify-team.sh",
      "./scripts/cleanup.sh"
    ]
  }
}
```

### Supported Commands

Hooks are triggered for these deploy commands:

- `sf project deploy start`
- `sf project deploy validate`
- `sf project deploy quick`
- `sf project deploy resume`

## Usage

### Pre-Deploy Hooks

Pre-deploy hooks run **before** the deploy command executes. If any hook fails (exits with non-zero status), the deploy is aborted.

Example `scripts/lint.sh`:

```bash
#!/bin/bash
set -e

echo "🔧 Running linter for command: ${SF_COMMAND}"
npm run lint

echo "✅ Linting passed"
```

### Post-Deploy Hooks

Post-deploy hooks run **after** the deploy command completes successfully. Hook failures are logged as warnings but don't affect the deploy.

Example `scripts/notify-team.sh`:

```bash
#!/bin/bash
set -e

echo "📢 Notifying team of deployment: ${SF_COMMAND}"
curl -X POST https://hooks.slack.com/... -d '{"text":"Deploy completed!"}'

echo "✅ Notification sent"
```

### AI-Assisted Error Analysis with Copilot CLI

Use Copilot CLI to automatically analyze deployment errors and suggest fixes:

Example `scripts/ai-analyze-errors.sh`:

```bash
#!/bin/bash
set -e

if [ -z "$SF_DEPLOY_RESULT_FILE" ] || [ ! -f "$SF_DEPLOY_RESULT_FILE" ]; then
  echo "✅ No deploy result to analyze"
  exit 0
fi

# Check for jq
if ! command -v jq &> /dev/null; then
  echo "⚠️  jq not installed, skipping AI analysis"
  exit 0
fi

# Check if deploy succeeded
SUCCESS=$(jq -r '.result.success // false' "$SF_DEPLOY_RESULT_FILE")

if [ "$SUCCESS" = "true" ]; then
  echo "✅ Deploy succeeded, no errors to analyze"
  exit 0
fi

echo "🤖 AI-powered error analysis starting..."
echo ""

# Parse component failures
jq -c '.result.details.componentFailures[]?' "$SF_DEPLOY_RESULT_FILE" | while read -r failure; do
  COMPONENT=$(echo "$failure" | jq -r '.fullName')
  COMPONENT_TYPE=$(echo "$failure" | jq -r '.componentType')
  PROBLEM=$(echo "$failure" | jq -r '.problem')
  LINE_NUM=$(echo "$failure" | jq -r '.lineNumber // "unknown"')
  
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "❌ Error in: $COMPONENT ($COMPONENT_TYPE)"
  echo "   Line: $LINE_NUM"
  echo "   Error: $PROBLEM"
  echo ""
  
  # Find the file path based on component type
  FILE_PATH=""
  case "$COMPONENT_TYPE" in
    ApexClass)
      FILE_PATH="force-app/main/default/classes/${COMPONENT}.cls"
      ;;
    ApexTrigger)
      FILE_PATH="force-app/main/default/triggers/${COMPONENT}.trigger"
      ;;
    LightningComponentBundle)
      FILE_PATH="force-app/main/default/lwc/${COMPONENT}/${COMPONENT}.js"
      ;;
    AuraDefinitionBundle)
      FILE_PATH="force-app/main/default/aura/${COMPONENT}/${COMPONENT}Controller.js"
      ;;
    *)
      echo "   ⚠️  Unknown component type, skipping file analysis"
      continue
      ;;
  esac
  
  # Check if file exists
  if [ ! -f "$FILE_PATH" ]; then
    echo "   ⚠️  File not found: $FILE_PATH"
    continue
  fi
  
  echo "🔍 Analyzing file: $FILE_PATH"
  echo ""
  
  # Use GitHub Copilot CLI to analyze the error
  # The error context is provided in the prompt
  gh copilot suggest "Analyze this Salesforce $COMPONENT_TYPE file and fix the deployment error: '$PROBLEM' at line $LINE_NUM. File: $FILE_PATH"
  
  echo ""
done

# Analyze test failures separately
TEST_FAILURES=$(jq -r '.result.details.runTestResult.failures // [] | length' "$SF_DEPLOY_RESULT_FILE")

if [ "$TEST_FAILURES" -gt 0 ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🧪 Test Failures Detected: $TEST_FAILURES"
  echo ""
  
  jq -c '.result.details.runTestResult.failures[]?' "$SF_DEPLOY_RESULT_FILE" | while read -r test_failure; do
    TEST_CLASS=$(echo "$test_failure" | jq -r '.name')
    TEST_METHOD=$(echo "$test_failure" | jq -r '.methodName')
    TEST_MESSAGE=$(echo "$test_failure" | jq -r '.message')
    
    echo "❌ Test: $TEST_CLASS.$TEST_METHOD"
    echo "   Error: $TEST_MESSAGE"
    echo ""
    
    TEST_FILE="force-app/main/default/classes/${TEST_CLASS}.cls"
    
    if [ -f "$TEST_FILE" ]; then
      echo "🔍 Analyzing test: $TEST_FILE"
      gh copilot suggest "Fix this failing Salesforce Apex test. Test method: $TEST_METHOD. Error: $TEST_MESSAGE. File: $TEST_FILE"
      echo ""
    fi
  done
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ AI analysis complete"
```

**Configure it:**

```json
{
  "hooks": {
    "postDeploy": [
      "./scripts/ai-analyze-errors.sh"
    ]
  }
}
```

This hook will:
1. Detect deployment failures automatically
2. Parse component and test errors from the deploy result
3. Locate the relevant source files
4. Use GitHub Copilot CLI to analyze each error and suggest fixes
5. Provide context-aware AI assistance for debugging

### Environment Variables

All hook scripts receive:

| Variable | Description |
|----------|-------------|
| `SF_COMMAND` | The sf command being executed (e.g., `project:deploy:start`) |
| `SF_DEPLOY_RESULT_FILE` | Path to JSON file containing deploy results (post-deploy hooks only) |

### Analyzing Deploy Results

Post-deploy hooks receive the full deploy result as a JSON file via the `SF_DEPLOY_RESULT_FILE` environment variable. This allows you to analyze errors, warnings, and deployment details.

Example `scripts/analyze-errors.sh`:

```bash
#!/bin/bash
set -e

if [ -z "$SF_DEPLOY_RESULT_FILE" ]; then
  echo "⚠️  No deploy result file available"
  exit 0
fi

echo "📊 Analyzing deployment results..."

# Check if jq is installed for JSON parsing
if ! command -v jq &> /dev/null; then
  echo "⚠️  jq not installed, showing raw result"
  cat "$SF_DEPLOY_RESULT_FILE"
  exit 0
fi

# Extract deployment status
SUCCESS=$(jq -r '.result.success // false' "$SF_DEPLOY_RESULT_FILE")

if [ "$SUCCESS" = "false" ]; then
  echo "❌ Deploy failed!"
  
  # Parse and display component failures
  jq -r '.result.details?.componentFailures[]? | "  - \(.fullName): \(.problemType) - \(.problem)"' "$SF_DEPLOY_RESULT_FILE"
  
  # Parse and display test failures
  jq -r '.result.details?.runTestResult?.failures[]? | "  - Test \(.name): \(.message)"' "$SF_DEPLOY_RESULT_FILE"
  
  # Send to error tracking service
  curl -X POST https://your-error-tracker.com/api/errors \
    -H "Content-Type: application/json" \
    -d @"$SF_DEPLOY_RESULT_FILE"
else
  echo "✅ Deploy succeeded!"
  
  # Log success metrics
  COMPONENTS=$(jq -r '.result.numberComponentsDeployed // 0' "$SF_DEPLOY_RESULT_FILE")
  echo "  📦 Deployed $COMPONENTS components"
fi
```

The deploy result JSON structure includes:

```json
{
  "command": "project:deploy:start",
  "argv": ["--target-org", "myorg"],
  "timestamp": "2026-02-01T23:30:00.000Z",
  "result": {
    "success": true,
    "status": "Succeeded",
    "id": "0Af...",
    "numberComponentsDeployed": 5,
    "numberComponentsTotal": 5,
    "details": {
      "componentSuccesses": [...],
      "componentFailures": [...],
      "runTestResult": {...}
    }
  }
}
```

### Multiple Hooks

Hooks execute sequentially in the order specified in the config. Each hook must complete successfully before the next one runs.

### Aborting a Deploy

Pre-deploy hooks can abort a deploy by exiting with non-zero status:

```bash
if [ ! -f "required-file.txt" ]; then
    echo "❌ Required file missing!"
    exit 1
fi
```

## Backward Compatibility

For backward compatibility, if no config file exists, the plugin will look for `./hooks/pre-deploy.sh` and execute it as a pre-deploy hook (legacy behavior).

## Uninstall

```bash
sf plugins uninstall @appollo-ui/sf-plugin-deploy-hooks
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Links

- [npm package](https://www.npmjs.com/package/@appollo-ui/sf-plugin-deploy-hooks)
- [GitHub repository](https://github.com/appollo-ui/sf-plugin-deploy-hooks)
- [Issues](https://github.com/appollo-ui/sf-plugin-deploy-hooks/issues)

## Development

```bash
cd local-dev/sf-plugin-deploy-hooks

# Watch for changes
npm run watch

# In another terminal, test the hooks
sf project deploy start --dry-run
```

## Example Configuration

### Basic Setup

```json
{
  "hooks": {
    "preDeploy": [
      "./scripts/validate-code.sh",
      "./scripts/run-tests.sh",
      "./scripts/check-dependencies.sh"
    ],
    "postDeploy": [
      "./scripts/warm-cache.sh",
      "./scripts/send-notifications.sh",
      "./scripts/update-docs.sh"
    ]
  }
}
```

### Advanced: Error Analysis

For comprehensive deploy error analysis, see the example script at `examples/analyze-deploy-errors.sh`:

```json
{
  "hooks": {
    "postDeploy": [
      "./examples/analyze-deploy-errors.sh"
    ]
  }
}
```

This example script demonstrates:
- Parsing deployment success/failure status
- Extracting component failures with error types
- Analyzing test failures and code coverage issues
- Formatting error reports for easy reading
- Integration points for error tracking services

### Advanced: AI-Powered Error Analysis 🤖

Use GitHub Copilot CLI to automatically analyze errors and get AI-powered fix suggestions:

```json
{
  "hooks": {
    "postDeploy": [
      "./examples/ai-analyze-errors.sh"
    ]
  }
}
```

**Prerequisites:**
- Install GitHub CLI: `brew install gh`
- Install Copilot: `gh extension install github/gh-copilot`
- Install jq: `brew install jq`

This will automatically:
1. Detect all deployment failures
2. Locate the problematic source files
3. Ask GitHub Copilot to explain each error
4. Provide AI-generated suggestions for fixes
5. Show you exactly where to look in your code

**Example output when a deploy fails:**
```
🤖 Starting AI-powered error analysis with GitHub Copilot...

❌ Component Error: MyClass (ApexClass)
   Location: Line 42
   Error: Variable does not exist: myVariabel

🔍 Analyzing: force-app/main/default/classes/MyClass.cls

💬 Asking GitHub Copilot for help...
[Copilot suggests: "Typo detected - 'myVariabel' should be 'myVariable'"]
```
