#!/bin/bash
set -e

echo "🔍 Analyzing deployment errors..."

# Check if deploy result file is available
if [ -z "$SF_DEPLOY_RESULT_FILE" ]; then
  echo "⚠️  No deploy result file available (SF_DEPLOY_RESULT_FILE not set)"
  exit 0
fi

if [ ! -f "$SF_DEPLOY_RESULT_FILE" ]; then
  echo "⚠️  Deploy result file not found: $SF_DEPLOY_RESULT_FILE"
  exit 0
fi

# Check if jq is installed for JSON parsing
if ! command -v jq &> /dev/null; then
  echo "⚠️  jq not installed - install with: brew install jq"
  echo "📄 Raw deploy result:"
  cat "$SF_DEPLOY_RESULT_FILE"
  exit 0
fi

# Extract key information
COMMAND=$(jq -r '.command // "unknown"' "$SF_DEPLOY_RESULT_FILE")
TIMESTAMP=$(jq -r '.timestamp // "unknown"' "$SF_DEPLOY_RESULT_FILE")
SUCCESS=$(jq -r '.result.success // false' "$SF_DEPLOY_RESULT_FILE")
STATUS=$(jq -r '.result.status // "unknown"' "$SF_DEPLOY_RESULT_FILE")

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Deployment Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Command:   $COMMAND"
echo "Time:      $TIMESTAMP"
echo "Status:    $STATUS"
echo "Success:   $SUCCESS"
echo ""

if [ "$SUCCESS" = "true" ]; then
  # Success metrics
  COMPONENTS_DEPLOYED=$(jq -r '.result.numberComponentsDeployed // 0' "$SF_DEPLOY_RESULT_FILE")
  COMPONENTS_TOTAL=$(jq -r '.result.numberComponentsTotal // 0' "$SF_DEPLOY_RESULT_FILE")
  TESTS_RUN=$(jq -r '.result.numberTestsTotal // 0' "$SF_DEPLOY_RESULT_FILE")
  
  echo "✅ Deployment Successful!"
  echo "   📦 Components: $COMPONENTS_DEPLOYED/$COMPONENTS_TOTAL deployed"
  
  if [ "$TESTS_RUN" -gt 0 ]; then
    TESTS_COMPLETED=$(jq -r '.result.numberTestsCompleted // 0' "$SF_DEPLOY_RESULT_FILE")
    echo "   🧪 Tests: $TESTS_COMPLETED/$TESTS_RUN passed"
  fi
  
else
  # Failure analysis
  echo "❌ Deployment Failed!"
  echo ""
  
  # Component failures
  COMPONENT_FAILURES=$(jq -r '.result.details.componentFailures // []' "$SF_DEPLOY_RESULT_FILE")
  FAILURE_COUNT=$(echo "$COMPONENT_FAILURES" | jq 'length')
  
  if [ "$FAILURE_COUNT" -gt 0 ]; then
    echo "🔴 Component Failures ($FAILURE_COUNT):"
    jq -r '.result.details.componentFailures[]? | "   [\(.problemType)] \(.fullName)\n      → \(.problem)"' "$SF_DEPLOY_RESULT_FILE"
    echo ""
  fi
  
  # Test failures
  TEST_FAILURES=$(jq -r '.result.details.runTestResult.failures // []' "$SF_DEPLOY_RESULT_FILE")
  TEST_FAILURE_COUNT=$(echo "$TEST_FAILURES" | jq 'length')
  
  if [ "$TEST_FAILURE_COUNT" -gt 0 ]; then
    echo "🔴 Test Failures ($TEST_FAILURE_COUNT):"
    jq -r '.result.details.runTestResult.failures[]? | "   [\(.methodName)] \(.name)\n      → \(.message)"' "$SF_DEPLOY_RESULT_FILE"
    echo ""
  fi
  
  # Code coverage issues
  CODE_COVERAGE=$(jq -r '.result.details.runTestResult.codeCoverage // []' "$SF_DEPLOY_RESULT_FILE")
  if [ "$CODE_COVERAGE" != "[]" ] && [ "$CODE_COVERAGE" != "null" ]; then
    echo "📊 Code Coverage Issues:"
    jq -r '.result.details.runTestResult.codeCoverage[]? | select(.numLocationsNotCovered > 0) | "   \(.name): \(.numLocationsCovered)/\((.numLocationsCovered + .numLocationsNotCovered)) lines covered"' "$SF_DEPLOY_RESULT_FILE"
  fi
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "💾 Full result available at: $SF_DEPLOY_RESULT_FILE"

# Optional: Send to error tracking service
# if [ "$SUCCESS" = "false" ]; then
#   echo "📤 Sending error report to tracking service..."
#   curl -X POST https://your-error-tracker.com/api/deploy-errors \
#     -H "Content-Type: application/json" \
#     -d @"$SF_DEPLOY_RESULT_FILE"
# fi
