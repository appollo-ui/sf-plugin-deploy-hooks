# Quick Start: AI-Powered Deploy Error Analysis

This guide will help you set up automatic AI-powered error analysis for your Salesforce deployments.

## Prerequisites

Install the required tools:

```bash
# 1. Install GitHub CLI
brew install gh

# 2. Authenticate with GitHub
gh auth login

# 3. Install GitHub Copilot extension
gh extension install github/gh-copilot

# 4. Install jq (JSON parser)
brew install jq

# 5. Verify installations
gh copilot --version
jq --version
```

## Setup

1. **Build and link the plugin** (if not already done):
   ```bash
   cd /path/to/sf-plugin-deploy-hooks
   npm run build
   sf plugins link .
   ```

2. **Create `.sfhooks.json` in your Salesforce project root**:
   ```json
   {
     "hooks": {
       "postDeploy": [
         "./node_modules/sf-plugin-deploy-hooks/examples/ai-analyze-errors.sh"
       ]
     }
   }
   ```

   Or copy the script locally:
   ```bash
   mkdir -p scripts
   cp examples/ai-analyze-errors.sh scripts/
   ```

   Then use:
   ```json
   {
     "hooks": {
       "postDeploy": ["./scripts/ai-analyze-errors.sh"]
     }
   }
   ```

## Usage

Just run your normal deploy commands - the AI analysis happens automatically on failures:

```bash
# Deploy to scratch org
sf project deploy start --target-org myorg

# If there are errors, you'll see:
# 🤖 Starting AI-powered error analysis with GitHub Copilot...
# ❌ Component Error: MyClass (ApexClass)
#    Location: Line 42
#    Error: Variable does not exist: myVariabel
# 
# 💬 Asking GitHub Copilot for help...
# [AI suggests: "Typo detected - 'myVariabel' should be 'myVariable'"]
```

## What It Does

1. **Detects failures** - Automatically identifies when a deploy fails
2. **Finds the files** - Locates the exact source files with errors
3. **Analyzes with AI** - Uses GitHub Copilot to explain each error
4. **Suggests fixes** - Provides specific recommendations to resolve issues
5. **Shows locations** - Tells you exactly where to look (file:line)

## Supported Component Types

The script handles these Salesforce component types:

- ✅ Apex Classes (`.cls`)
- ✅ Apex Triggers (`.trigger`)
- ✅ Lightning Web Components (`.js`)
- ✅ Aura Components (`.js`)
- ✅ Visualforce Pages (`.page`)
- ✅ Visualforce Components (`.component`)
- ✅ Apex Test Failures

## Tips

### Customize the Analysis

Edit `ai-analyze-errors.sh` to customize:
- File path patterns for your project structure
- The prompts sent to Copilot
- Output formatting
- Additional error types to analyze

### Use Interactive Mode

After seeing automated suggestions, you can continue with interactive Copilot:

```bash
# Ask follow-up questions
gh copilot suggest "How do I fix the test coverage issue in MyClass?"

# Get explanations
gh copilot explain "What causes 'Variable does not exist' in Apex?"
```

### Combine with Other Hooks

Stack multiple post-deploy hooks:

```json
{
  "hooks": {
    "postDeploy": [
      "./scripts/analyze-deploy-errors.sh",
      "./scripts/ai-analyze-errors.sh",
      "./scripts/notify-on-error.sh"
    ]
  }
}
```

### Disable Temporarily

To skip AI analysis for a single deploy:

```bash
# Remove the config temporarily
mv .sfhooks.json .sfhooks.json.bak
sf project deploy start
mv .sfhooks.json.bak .sfhooks.json
```

## Troubleshooting

### "gh: command not found"
```bash
brew install gh
gh auth login
```

### "Copilot unavailable"
```bash
gh extension install github/gh-copilot
# Or update: gh extension upgrade gh-copilot
```

### "jq: command not found"
```bash
brew install jq
```

### File paths don't match your structure

Edit the script's `case` statement around line 50 to match your project layout:

```bash
case "$COMPONENT_TYPE" in
  ApexClass)
    FILE_PATH="src/classes/${COMPONENT}.cls"  # Your custom path
    ;;
esac
```

### Script runs but shows no output

Check that deploy errors exist:
```bash
cat /tmp/sf-deploy-hooks/deploy-result-*.json | jq '.result.success'
```

## More Examples

See `examples/README.md` for additional scripts:
- `analyze-deploy-errors.sh` - Detailed error reporting without AI
- `notify-on-error.sh` - Send Slack notifications on failures

## Learn More

- GitHub Copilot CLI: https://docs.github.com/en/copilot/github-copilot-in-the-cli
- Plugin README: `../README.md`
- SF CLI Hooks: https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/
