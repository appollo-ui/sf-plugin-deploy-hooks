#!/bin/bash

# Simple script to send Slack notification on deploy failures

if [ -z "$SF_DEPLOY_RESULT_FILE" ] || [ ! -f "$SF_DEPLOY_RESULT_FILE" ]; then
  echo "⚠️  No deploy result available"
  exit 0
fi

# Check if jq is available
if ! command -v jq &> /dev/null; then
  echo "⚠️  jq not installed, skipping notification"
  exit 0
fi

# Extract deploy status
SUCCESS=$(jq -r '.result.success // false' "$SF_DEPLOY_RESULT_FILE")

if [ "$SUCCESS" = "false" ]; then
  echo "📢 Deploy failed, sending notification..."
  
  # Get error details
  COMMAND=$(jq -r '.command' "$SF_DEPLOY_RESULT_FILE")
  ERROR_COUNT=$(jq -r '.result.details.componentFailures | length' "$SF_DEPLOY_RESULT_FILE")
  
  # Build error summary
  ERRORS=$(jq -r '.result.details.componentFailures[]? | "• \(.fullName): \(.problem)"' "$SF_DEPLOY_RESULT_FILE" | head -5)
  
  # Send to Slack (replace with your webhook URL)
  SLACK_WEBHOOK="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
  
  MESSAGE=$(cat <<EOF
{
  "text": "⚠️ Salesforce Deployment Failed",
  "blocks": [
    {
      "type": "header",
      "text": {
        "type": "plain_text",
        "text": "❌ Deploy Failed: $COMMAND"
      }
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "*$ERROR_COUNT component failures*\n\n$ERRORS"
      }
    }
  ]
}
EOF
  )
  
  # Uncomment to enable Slack notifications:
  # curl -X POST "$SLACK_WEBHOOK" \
  #   -H "Content-Type: application/json" \
  #   -d "$MESSAGE"
  
  echo "✅ Notification sent"
else
  echo "✅ Deploy succeeded, no notification needed"
fi
