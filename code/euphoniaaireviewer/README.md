# Euphonia AI Reviewer - Flutter mobile app

Flutter app for Euphonia AI Reviewer.


# Getting Started

## Installation

1. Clone the repository:

```bash
git clone https://github.com/TropicodeLabs/Euphonia-AI-Reviewer.git
```

2. Navigate to the `mobile_app` directory:

```bash
cd Euphonia-AI-Reviewer/mobile_app
```

3. Install dependencies and create android/ios directories:

```bash
flutter pub get

flutter create .
```

To avoid having to replace the default package name com.example.yourappname, you could instead do

```bash
cd ..

mv mobile_app yourappname

flutter create yourappname --org com.yourcompany
```

4. Configure app icon using [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons):

```bash
flutter pub run flutter_launcher_icons
```

5. Configure backend services (Google Firebase):

Make sure you already have a Firebase project set up. If not, follow these general steps, and refer to this [link](https://firebase.google.com/docs/flutter/setup) for more detailed information.

1. Go to the [Firebase Console](https://console.firebase.google.com/). Sign in with your Google account.
2. Click on **Add Project** and follow the steps to create a new Firebase project.
3. Register your app with Firebase:
    - For Android, download the `google-services.json` file.
    - For iOS, download the `GoogleService-Info.plist` file.
4. Add these files to your project:
    - `google-services.json` should be placed in `android/app/`.
    - `GoogleService-Info.plist` should be placed in `ios/Runner/`.

Run the following command to configure Firebase services :

```bash
flutterfire configure
```

6. Prepare build

In Android:

Modify the android app name in `android/app/src/main/AndroidManifest.xml`:

```xml
<application
    android:label="Euphonia AI Reviewer"
    ... REST OF THE FILE ...
```

# Notes on cybersecurity and privacy:
- We are not responsible for any data breaches or other security incidents that may occur as a result of using this software.
- Do not publish or share the following sensitive files files: `google-services.json`, `GoogleService-Info.plist`, firebase_options.dart, or others that may contain sensitive information.