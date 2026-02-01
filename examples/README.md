# Post-Deploy Hook Examples

This directory contains example scripts demonstrating how to analyze deployment results in post-deploy hooks.

## Available Examples

### 1. analyze-deploy-errors.sh
Comprehensive deployment analysis script that:
- Parses deployment success/failure status
- Lists component failures with error types
- Shows test failures and stack traces
- Displays code coverage issues
- Provides structured error reporting

**Usage:**
```json
{
  "hooks": {
    "postDeploy": ["./examples/analyze-deploy-errors.sh"]
  }
}
```

### 2. notify-on-error.sh
Simple notification script for deployment failures:
- Detects deploy failures
- Formats error summary
- Sends Slack notification (configurable)
- Only notifies on failures

**Usage:**
```json
{
  "hooks": {
    "postDeploy": ["./examples/notify-on-error.sh"]
  }
}
```

### 3. ai-analyze-errors.sh ⭐
AI-powered error analysis using GitHub Copilot CLI:
- Automatically detects deployment failures
- Identifies failed components and tests
- Locates source files
- Uses GitHub Copilot to explain errors and suggest fixes
- Provides interactive AI assistance for debugging

**Prerequisites:**
- GitHub CLI: `brew install gh`
- GitHub Copilot CLI extension
- jq: `brew install jq`

**Usage:**
```json
{
  "hooks": {
    "postDeploy": ["./examples/ai-analyze-errors.sh"]
  }
}
```

**Example Output:**
```
🤖 Starting AI-powered error analysis with GitHub Copilot...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
❌ Component Error: AccountTrigger (ApexTrigger)
   Location: Line 15, Column 23
   Error: Variable does not exist: acccount

🔍 Analyzing: force-app/main/default/triggers/AccountTrigger.trigger

💬 Asking GitHub Copilot for help...

[Copilot suggests fixing the typo: 'acccount' → 'account']

📝 To view the file:
   code force-app/main/default/triggers/AccountTrigger.trigger:15
```

## Deploy Result Structure

The `SF_DEPLOY_RESULT_FILE` environment variable points to a JSON file with this structure:

```json
{
  "command": "project:deploy:start",
  "argv": ["--target-org", "production"],
  "timestamp": "2026-02-01T23:30:00.000Z",
  "result": {
    "success": true,
    "status": "Succeeded",
    "id": "0Af...",
    "numberComponentsDeployed": 10,
    "numberComponentsTotal": 10,
    "numberTestsTotal": 25,
    "numberTestsCompleted": 25,
    "details": {
      "componentSuccesses": [
        {
          "fullName": "MyClass",
          "componentType": "ApexClass",
          "created": false,
          "changed": true
        }
      ],
      "componentFailures": [
        {
          "fullName": "FailedClass",
          "componentType": "ApexClass",
          "problemType": "Error",
          "problem": "Invalid syntax at line 10"
        }
      ],
      "runTestResult": {
        "failures": [
          {
            "name": "MyTestClass",
            "methodName": "testMethod",
            "message": "System.AssertException: Assertion Failed",
            "stackTrace": "Class.MyTestClass.testMethod: line 15"
          }
        ],
        "codeCoverage": [
          {
            "name": "MyClass",
            "numLocationsCovered": 10,
            "numLocationsNotCovered": 2
          }
        ]
      }
    }
  }
}
```

## Common Use Cases

### Extract All Errors
```bash
jq -r '.result.details.componentFailures[]? | "\(.fullName): \(.problem)"' "$SF_DEPLOY_RESULT_FILE"
```

### Check Deploy Success
```bash
SUCCESS=$(jq -r '.result.success' "$SF_DEPLOY_RESULT_FILE")
if [ "$SUCCESS" = "true" ]; then
  echo "Deploy succeeded!"
fi
```

### Count Component Failures
```bash
FAILURE_COUNT=$(jq -r '.result.details.componentFailures | length' "$SF_DEPLOY_RESULT_FILE")
```

### Get Test Coverage
```bash
jq -r '.result.details.runTestResult.codeCoverage[]? | "\(.name): \(.numLocationsCovered)/\((.numLocationsCovered + .numLocationsNotCovered))"' "$SF_DEPLOY_RESULT_FILE"
```

## Prerequisites

Most examples use `jq` for JSON parsing:

```bash
# macOS
brew install jq

# Ubuntu/Debian
apt-get install jq

# Windows (via Chocolatey)
choco install jq
```

## Custom Integration Examples

### Send to Error Tracking Service
```bash
if [ "$SUCCESS" = "false" ]; then
  curl -X POST https://api.sentry.io/... \
    -H "Content-Type: application/json" \
    -d @"$SF_DEPLOY_RESULT_FILE"
fi
```

### Write to Log File
```bash
LOG_DIR="./deploy-logs"
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
cp "$SF_DEPLOY_RESULT_FILE" "$LOG_DIR/deploy-$TIMESTAMP.json"
```

### Generate HTML Report
```bash
jq -r '...' "$SF_DEPLOY_RESULT_FILE" > report.html
```
