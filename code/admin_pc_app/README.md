# Euphonia AI-Reviewer Admin Web App

Manage your Euphonia-AI-Reviewer projects.

# Getting Started

## Installation

### 1. Clone the repository:

```bash
git clone https://github.com/TropicodeLabs/Euphonia-AI-Reviewer.git
```

### 2. Navigate to the `admin_pc_app` directory:

```bash
cd Euphonia-AI-Reviewer/code/admin_pc_app
```

### 3. Install dependencies:

This command will install all the required dependencies for the project. It will also create a new Flutter project in the admin_pc_app directory, specifically set up for web by creating the web directory and configuring the project accordingly.

```bash
flutter create . --platforms=web
```

### 4. Configure the project:

#### a. Remove default unwanted files (optional):
You may also delete the default test files that were created by `flutter create .` command. You can do this by running the following command:

```bash
rm -r test
```

Note: it would be great to have tests for the app. For now, we are focusing on the app's core functionality. It would be great if you could contribute by adding tests to the app and submitting a pull request. 🚀

#### b. Configure Firebase services:

Make sure you already have a Firebase project set up. If not, follow these general steps, and refer to this [link](https://firebase.google.com/docs/flutter/setup) for more detailed information.

Run the following command to configure Firebase services:

```bash
flutterfire configure
```

- It will ask you which Firebase project you want to use. If you do not have a Firebase project set up, you can create one by selecting the option to create a new project. Otherwise, select the project you want to use.
- Then you will have to choose the platform you want to configure. Select the macOS option.

### 5. Prepare to build the app:

### 7. Run the app:

You can run the app by running the following command:

```bash
flutter run -d chrome --web-renderer html
```

### 8. Build the app for release:

Follow the steps in the [official documentation](https://docs.flutter.dev/deployment/macos) to build the app for release.

```bash
flutter build web
```

### 9. Deploy the app:

```bash
firebase deploy
```

# Notes on cybersecurity and privacy:
- We are not responsible for any data breaches or other security incidents that may occur as a result of using this software.
- Do not publish or share the following sensitive files files: `google-services.json`, `GoogleService-Info.plist`, `firebase_options.dart` or others that may contain sensitive information.