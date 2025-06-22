# Firebase Storage CORS Configuration

## Problem
The Euphonia AI Reviewer app works when running with `--disable-web-security` flag but fails in normal browsers due to CORS (Cross-Origin Resource Sharing) restrictions when trying to stream audio from Firebase Storage.

## Development Workaround
```bash
flutter run -d chrome --web-browser-flag "--disable-web-security"
```

## Production Solution
Configure Firebase Storage CORS headers to allow audio streaming.

### Step 1: Install Google Cloud SDK
1. Install Google Cloud SDK from: https://cloud.google.com/sdk/docs/install
2. Authenticate: `gcloud auth login`
3. Set project: `gcloud config set project YOUR_PROJECT_ID`

### Step 2: Apply CORS Configuration
```bash
# Run the setup script
./setup_cors.sh
```

Or manually:
```bash
# Apply CORS configuration to your Firebase Storage bucket
gsutil cors set cors.json gs://YOUR_PROJECT_ID.appspot.com
```

### Step 3: Verify CORS Configuration
```bash
gsutil cors get gs://YOUR_PROJECT_ID.appspot.com
```

## CORS Configuration Details
The `cors.json` file contains:
- **Origin**: `*` (allows all origins - can be restricted to your domain)
- **Methods**: `GET`, `HEAD` (required for audio streaming)
- **Headers**: Standard headers for Firebase Storage
- **MaxAge**: 3600 seconds (1 hour cache)

## For Production
Consider restricting the origin to your specific domain:
```json
{
  "origin": ["https://yourdomain.com", "https://www.yourdomain.com"],
  "method": ["GET", "HEAD"],
  "maxAgeSeconds": 3600,
  "responseHeader": ["Content-Type", "Access-Control-Allow-Origin", "x-goog-resumable"]
}
```

## Troubleshooting
1. **Permission denied**: Make sure you have Firebase Admin privileges
2. **Bucket not found**: Verify your project ID and bucket name
3. **Still not working**: Clear browser cache and try again
4. **Mobile apps**: CORS only affects web browsers, mobile apps should work without CORS configuration

## Alternative Solutions
1. **Convert to MP3**: WAV files have limited browser support
2. **Use Firebase Functions**: Serve audio through Cloud Functions with proper headers
3. **CDN**: Use a CDN with proper CORS configuration
