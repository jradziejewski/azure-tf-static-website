#!/bin/bash

set -e

echo "================================================================"
echo "👍 Starting deployment of the static website to Azure Storage..."
echo "================================================================"

echo "🚀 Step 1: Provisioning infrastructure and uploading frontend..."
terraform apply -auto-approve

echo "📦 Step 2: Retrieving website URL..."
WEBSITE_URL=$(terraform output -raw website_url)
echo "✅ Deployment completed successfully!"
echo "🌐 Your static website is now live at: $WEBSITE_URL"

echo "⏱️ Waiting for DNS propagation..."
sleep 10

echo "🧪 Step 3: Running automated integration tests..."

# Test A: Check if HTTP status is 200
HTTP_STATUS=$(curl -o /dev/null -s -w "%{http_code}" "$WEBSITE_URL")
if [ "$HTTP_STATUS" -eq 200 ]; then
    echo "✅ Test A Passed: HTTP status is 200"
else
    echo "❌ Test A Failed: HTTP status is $HTTP_STATUS"
    exit 1
fi

# Test B: Check if the content contains a specific string
EXPECTED_STRING="Hello Azure!"
ACTUAL_CONTENT=$(curl -s "$WEBSITE_URL")

if [[ "$ACTUAL_CONTENT" == *"$EXPECTED_STRING"* ]]; then
    echo "✅ Test B Passed: Content contains the expected string"
else
    echo "❌ Test B Failed: Content does not contain the expected string"
    exit 1
fi

echo "==============================================================="
echo "🎉 All tests passed! Your static website is live and functioning correctly."
echo "==============================================================="