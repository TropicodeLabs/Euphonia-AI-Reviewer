# Euphonia AI-Reviewer Admin PC App

Manage your Euphonia-AI-Reviewer projects.

⚠️ **IMPORTANT**: This app is only available for macOS at the moment. 💻

We are planning to release Windows and Web versions soon. Or even better, you can help us by contributing to the project. 🚀

# Getting Started

## Installation

### 1. Clone the repository:

```bash
git clone https://github.com/TropicodeLabs/Euphonia-AI-Reviewer.git
```

### 2. Navigate to the `admin_pc_app` directory:

```bash
cd Euphonia-AI-Reviewer/admin_pc_app
```

### 3. Install dependencies:

```bash
flutter create . --platforms=macos
```

These commands will create a new Flutter project in the current directory and install the required dependencies. ⚠️ IMPORTANT: Some of the files created might have default values that you may want to change. For instance, the project uses a default bundle identifier, which you may want to change to match your project's bundle identifier. For example, com.example.myapp may be the default bundle identifier, but you may want to change it to com.mycompany.myapp to match your project's bundle identifier, which is important for Firebase configuration. We will do this in the next steps.

### 4. Configure the project:

#### a. Change the package name:
You can change the bundle identifier for this macOS app by opening the `macos/Runner.xcworkspace` file in Xcode, selecting the `Runner` project in the left sidebar, and changing the bundle identifier in the `Signing & Capabilities` tab.

#### b. Change the app name:
You can change the app name by opening the `macos/Runner/Info.plist` file and changing the value of the `CFBundleName` key.

#### c. Change the app icon:
You can change the app icon by replacing the `macos/Runner/Assets.xcassets/AppIcon.appiconset` folder with your own app icon assets.

#### d. Remove default unwanted files:
You may also delete the default test files that were created by `flutter create .` command. You can do this by running the following command:

```bash
rm -r test
```

### 5. Configure backend services (Google Firebase):

Make sure you already have a Firebase project set up. If not, follow these general steps, and refer to this [link](https://firebase.google.com/docs/flutter/setup) for more detailed information.

<ol type="a">
  <li> Go to the [Firebase Console](https://console.firebase.google.com/). Sign in with your Google account.
    <li> Click on **Add Project** and follow the steps to create a new Firebase project.
    <li> Register your app with Firebase:
      <ul>
        <li> For Android, download the `google-services.json` file.
        <li> For iOS, download the `GoogleService-Info.plist` file.
      </ul>
    <li> Add these files to your project:
        <ul>
            <li> `google-services.json` should be placed in `android/app/`.
            <li> `GoogleService-Info.plist` should be placed in `ios/Runner/`.
        </ul>
</ol>

Run the following command to configure Firebase services :

```bash
flutterfire configure
```

### 6. Prepare build

# Notes on cybersecurity and privacy:
- We are not responsible for any data breaches or other security incidents that may occur as a result of using this software.
- Do not publish or share the following sensitive files files: `google-services.json`, `GoogleService-Info.plist`, `firebase_options.dart` or others that may contain sensitive information.