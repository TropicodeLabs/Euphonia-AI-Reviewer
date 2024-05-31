# Euphonia AI-Reviewer Admin PC App

Manage your Euphonia-AI-Reviewer projects

# Getting Started

## Installation

1. Clone the repository:

```bash
git clone https://github.com/TropicodeLabs/Euphonia-AI-Reviewer.git
```

2. Navigate to the `admin_pc_app` directory:

```bash
cd Euphonia-AI-Reviewer/admin_pc_app
```

3. Install dependencies:

```bash
flutter pub get
```

4. Configure backend services (Google Firebase):

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

5. Prepare build

# Notes on cybersecurity and privacy:
- We are not responsible for any data breaches or other security incidents that may occur as a result of using this software.
- Do not publish or share the following sensitive files files: `google-services.json`, `GoogleService-Info.plist`, `firebase_options.dart` or others that may contain sensitive information.