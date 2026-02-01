#!/bin/bash
set -e

# AI-powered error analysis using GitHub Copilot CLI
# This script analyzes deployment failures and uses Copilot to suggest fixes

if [ -z "$SF_DEPLOY_RESULT_FILE" ] || [ ! -f "$SF_DEPLOY_RESULT_FILE" ]; then
  echo "✅ No deploy result to analyze"
  exit 0
fi

# Check for jq
if ! command -v jq &> /dev/null; then
  echo "⚠️  jq not installed - install with: brew install jq"
  exit 0
fi

# Check for GitHub Copilot CLI
if ! command -v gh &> /dev/null; then
  echo "⚠️  GitHub CLI (gh) not installed - install with: brew install gh"
  exit 0
fi

# Check if deploy succeeded
SUCCESS=$(jq -r '.result.success // false' "$SF_DEPLOY_RESULT_FILE")

if [ "$SUCCESS" = "true" ]; then
  echo "✅ Deploy succeeded, no errors to analyze"
  exit 0
fi

echo "🤖 Starting AI-powered error analysis with GitHub Copilot..."
echo ""

# Counter for errors analyzed
ERRORS_ANALYZED=0

# Parse component failures
jq -c '.result.details.componentFailures[]?' "$SF_DEPLOY_RESULT_FILE" | while read -r failure; do
  COMPONENT=$(echo "$failure" | jq -r '.fullName')
  COMPONENT_TYPE=$(echo "$failure" | jq -r '.componentType')
  PROBLEM=$(echo "$failure" | jq -r '.problem')
  LINE_NUM=$(echo "$failure" | jq -r '.lineNumber // "unknown"')
  COLUMN_NUM=$(echo "$failure" | jq -r '.columnNumber // ""')
  
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "❌ Component Error: $COMPONENT ($COMPONENT_TYPE)"
  echo "   Location: Line $LINE_NUM$([ -n "$COLUMN_NUM" ] && echo ", Column $COLUMN_NUM")"
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
      # Try to find the main JS file
      if [ -f "force-app/main/default/lwc/${COMPONENT}/${COMPONENT}.js" ]; then
        FILE_PATH="force-app/main/default/lwc/${COMPONENT}/${COMPONENT}.js"
      elif [ -d "force-app/main/default/lwc/${COMPONENT}" ]; then
        FILE_PATH="force-app/main/default/lwc/${COMPONENT}"
      fi
      ;;
    AuraDefinitionBundle)
      if [ -f "force-app/main/default/aura/${COMPONENT}/${COMPONENT}Controller.js" ]; then
        FILE_PATH="force-app/main/default/aura/${COMPONENT}/${COMPONENT}Controller.js"
      elif [ -d "force-app/main/default/aura/${COMPONENT}" ]; then
        FILE_PATH="force-app/main/default/aura/${COMPONENT}"
      fi
      ;;
    ApexPage)
      FILE_PATH="force-app/main/default/pages/${COMPONENT}.page"
      ;;
    ApexComponent)
      FILE_PATH="force-app/main/default/components/${COMPONENT}.component"
      ;;
    *)
      echo "   ⚠️  Unknown component type: $COMPONENT_TYPE"
      echo "   💡 Try manually checking the component"
      echo ""
      continue
      ;;
  esac
  
  # Check if file exists
  if [ ! -f "$FILE_PATH" ]; then
    echo "   ⚠️  File not found: $FILE_PATH"
    echo "   💡 The file may be in a different directory structure"
    echo ""
    continue
  fi
  
  echo "🔍 Analyzing: $FILE_PATH"
  echo ""
  
  # Build the prompt for Copilot
  PROMPT="I have a Salesforce deployment error in a $COMPONENT_TYPE file.

File: $FILE_PATH
Error at line $LINE_NUM: $PROBLEM

Please analyze the file and suggest how to fix this error. Provide specific code changes if possible."
  
  # Use GitHub Copilot CLI to get suggestions
  echo "💬 Asking GitHub Copilot for help..."
  echo ""
  
  # Try copilot suggest, fallback to explain
  if gh copilot suggest "$PROMPT" 2>/dev/null; then
    ERRORS_ANALYZED=$((ERRORS_ANALYZED + 1))
  else
    echo "   ℹ️  Using copilot explain instead..."
    gh copilot explain "$PROBLEM in $FILE_PATH at line $LINE_NUM" 2>/dev/null || echo "   ⚠️  Copilot unavailable"
  fi
  
  echo ""
  echo "📝 To view the file:"
  echo "   code $FILE_PATH:$LINE_NUM"
  echo ""
done

# Analyze test failures
TEST_FAILURES=$(jq -r '.result.details.runTestResult.failures // [] | length' "$SF_DEPLOY_RESULT_FILE")

if [ "$TEST_FAILURES" -gt 0 ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🧪 Test Failures Detected: $TEST_FAILURES"
  echo ""
  
  jq -c '.result.details.runTestResult.failures[]?' "$SF_DEPLOY_RESULT_FILE" | while read -r test_failure; do
    TEST_CLASS=$(echo "$test_failure" | jq -r '.name')
    TEST_METHOD=$(echo "$test_failure" | jq -r '.methodName')
    TEST_MESSAGE=$(echo "$test_failure" | jq -r '.message')
    STACK_TRACE=$(echo "$test_failure" | jq -r '.stackTrace // ""')
    
    echo "❌ Test Failure: $TEST_CLASS.$TEST_METHOD"
    echo "   Error: $TEST_MESSAGE"
    if [ -n "$STACK_TRACE" ]; then
      echo "   Stack: $STACK_TRACE"
    fi
    echo ""
    
    TEST_FILE="force-app/main/default/classes/${TEST_CLASS}.cls"
    
    if [ -f "$TEST_FILE" ]; then
      echo "🔍 Analyzing test: $TEST_FILE"
      echo ""
      
      PROMPT="I have a failing Salesforce Apex test.

Test class: $TEST_CLASS
Test method: $TEST_METHOD
Error: $TEST_MESSAGE
$([ -n "$STACK_TRACE" ] && echo "Stack trace: $STACK_TRACE")

Please help me understand why this test is failing and suggest a fix."
      
      echo "💬 Asking GitHub Copilot for help..."
      echo ""
      
      if gh copilot suggest "$PROMPT" 2>/dev/null; then
        ERRORS_ANALYZED=$((ERRORS_ANALYZED + 1))
      else
        gh copilot explain "$TEST_MESSAGE in test $TEST_CLASS.$TEST_METHOD" 2>/dev/null || echo "   ⚠️  Copilot unavailable"
      fi
      
      echo ""
      echo "📝 To view the test:"
      echo "   code $TEST_FILE"
      echo ""
    else
      echo "   ⚠️  Test file not found: $TEST_FILE"
      echo ""
    fi
  done
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$ERRORS_ANALYZED" -gt 0 ]; then
  echo "✅ AI analysis complete - analyzed $ERRORS_ANALYZED error(s)"
else
  echo "ℹ️  No errors could be analyzed automatically"
  echo "   View full results: cat $SF_DEPLOY_RESULT_FILE"
fi

echo ""
echo "💡 Tip: You can also run 'gh copilot' directly for interactive help"
