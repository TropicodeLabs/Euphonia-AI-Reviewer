#!/bin/bash

# Firebase Storage CORS Configuration Script
# This script sets up CORS headers for Firebase Storage to allow audio streaming in web browsers

echo "🔧 Configuring Firebase Storage CORS..."

# Check if gcloud CLI is installed
if ! command -v gsutil &> /dev/null; then
    echo "❌ Error: Google Cloud SDK (gsutil) is not installed."
    echo "📋 Please install it from: https://cloud.google.com/sdk/docs/install"
    echo ""
    echo "📋 After installation, run:"
    echo "   gcloud auth login"
    echo "   gcloud config set project YOUR_PROJECT_ID"
    exit 1
fi

# Check if cors.json exists
if [ ! -f "cors.json" ]; then
    echo "❌ Error: cors.json file not found in current directory"
    echo "📋 Make sure you're running this script from the project root where cors.json is located"
    exit 1
fi

# Get the Firebase project ID (you'll need to replace this with your actual project ID)
PROJECT_ID="birdnet-reviewer"
BUCKET_NAME="${PROJECT_ID}.appspot.com"

echo "🔍 Project ID: $PROJECT_ID"
echo "🔍 Bucket: $BUCKET_NAME"

# Apply CORS configuration
echo "🚀 Applying CORS configuration to Firebase Storage bucket..."
gsutil cors set cors.json gs://$BUCKET_NAME

if [ $? -eq 0 ]; then
    echo "✅ CORS configuration applied successfully!"
    echo ""
    echo "📋 You can now test your app without --disable-web-security flag"
    echo "📋 Audio streaming should work in production browsers"
    echo ""
    echo "🔍 To verify CORS settings:"
    echo "   gsutil cors get gs://$BUCKET_NAME"
else
    echo "❌ Failed to apply CORS configuration"
    echo "📋 Make sure you're authenticated and have permissions to modify the storage bucket"
    echo "📋 Run: gcloud auth login"
fi
