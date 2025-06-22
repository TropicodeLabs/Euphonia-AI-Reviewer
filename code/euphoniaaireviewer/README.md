# Euphonia AI Reviewer - PWA Flutter App

Flutter Progressive Web App (PWA) for Euphonia AI Reviewer - migrated from mobile to web-only for better cross-platform compatibility.

## 🌟 Features

- **Web-only PWA** - No mobile app installation required
- **Audio streaming** from Firebase Storage
- **Real-time spectrogram computation** from streamed audio using FFT analysis
- **Interactive spectrograms** with customizable colormaps (jet, grayscale)
- **Manual species input** and clickable species list
- **Cross-platform compatibility** - works in any modern web browser

## 🚀 Getting Started

### Prerequisites

For normal development:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable version)
- [Firebase and FlutterFire](https://firebase.google.com/docs/flutter/setup?platform=web) (for Flutter-Firebase integration)

Optional, to configure CORS:
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) (for CORS configuration)

### 1. Clone and Setup

```bash
# Clone the repository, make sure you pull the branch that you want to work on
git clone https://github.com/TropicodeLabs/Euphonia-AI-Reviewer.git
git checkout macos-to-web

# Navigate to the app directory
cd Euphonia-AI-Reviewer/code/euphoniaaireviewer

# Install Flutter dependencies
flutter pub get
```

### 2. Firebase Configuration

```bash
# Configure Firebase for your project
flutterfire configure
# Select your Firebase project (e.g., birdnet-reviewer)
```

### 3. CORS Configuration (Required for Audio Streaming) 

This needs to be done only once.

The app requires CORS configuration on Firebase Storage to stream audio files in web browsers.

#### Install Google Cloud SDK
1. Install from: https://cloud.google.com/sdk/docs/install
2. Authenticate: `gcloud auth login`
3. Set your project: `gcloud config set project YOUR_PROJECT_ID`

#### Apply CORS Settings
```bash
# Make the script executable
chmod +x setup_cors.sh

# Run the CORS configuration script
./setup_cors.sh
```

**Alternative manual method:**
```bash
gsutil cors set cors.json gs://YOUR_PROJECT_ID.appspot.com
```

### 4. Development Mode

#### Option A: Normal Mode (after CORS setup)
```bash
flutter run -d chrome --web-renderer html
```

#### Option B: Development Mode (bypasses CORS - for testing only)
```bash
flutter run -d chrome --web-browser-flag "--disable-web-security"
```

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── web_audio_service.dart       # PWA audio streaming service
├── web_audio_processing.dart    # Real-time spectrogram computation via FFT
├── spectrogram_display.dart     # Spectrogram visualization widget
├── spectrogram_widget.dart      # Interactive spectrogram component
├── play_screen.dart             # Manual species input screen
├── example_card.dart            # Audio clip card component
└── ...
cors.json                        # Firebase Storage CORS configuration
setup_cors.sh                   # CORS setup script
CORS_SETUP.md                   # Detailed CORS documentation
```

## 🔧 Key Differences from Mobile Version

### Removed Dependencies
- ❌ `wav` - Not compatible with web
- ❌ `path_provider` - File system access not needed for PWA
- ❌ `qr_code_scanner` - Not reliable on web, replaced with manual input
- ❌ `dart:io` - Not available in web context

### Added PWA Features
- ✅ **Web Audio Service** - Streams audio directly from Firebase Storage URLs
- ✅ **Real-time Spectrograms** - FFT-based computation from streamed audio data
- ✅ **Manual Input** - Text input and clickable species list instead of QR scanner
- ✅ **CORS Support** - Proper configuration for cross-origin audio streaming

## 🐛 Troubleshooting

### Audio Not Playing
1. **Check CORS configuration**: Run `gsutil cors get gs://YOUR_PROJECT_ID.appspot.com`
2. **Browser compatibility**: WAV files may not work in all browsers - consider converting to MP3
3. **Development mode**: Use `--disable-web-security` flag for testing

### Spectrogram Not Loading
1. **Check console logs**: Look for detailed debug output with 🔍 prefix
2. **Firebase permissions**: Ensure your Firebase Storage rules allow read access
3. **Network issues**: Check if Firebase Storage URLs are accessible

### CORS Errors
```bash
# Verify CORS settings
gsutil cors get gs://YOUR_PROJECT_ID.appspot.com

# Re-apply if needed
./setup_cors.sh
```

## 🚀 Production Deployment

### Build for Production
```bash
flutter build web --web-renderer html
```

### Deploy to Firebase Hosting
```bash
firebase init hosting
firebase deploy
```

### Important Notes for Production
- Audio files should be in MP3 or AAC format for better browser compatibility
- CORS must be properly configured (no `--disable-web-security` in production)
- Consider CDN for audio files if performance is critical

## 📚 Documentation

- [CORS Setup Guide](CORS_SETUP.md) - Detailed CORS configuration instructions
- [Flutter Web Documentation](https://docs.flutter.dev/platform-integration/web)
- [Firebase Storage CORS](https://firebase.google.com/docs/storage/web/download-files#cors_configuration)

## 🤝 Contributing

When contributing to the PWA version:

1. **Test with CORS**: Always test with proper CORS configuration, not just `--disable-web-security`
2. **Web Compatibility**: Ensure all dependencies support web platform
3. **Audio Formats**: Use web-compatible audio formats (MP3, AAC, OGG)
4. **Debug Prints**: Include 🔍 prefix for debug output to help troubleshooting