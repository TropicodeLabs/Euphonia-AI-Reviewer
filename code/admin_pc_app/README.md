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
cd Euphonia-AI-Reviewer/code/admin_pc_app
```

### 3. Install dependencies:

This command will install all the required dependencies for the project. It will also create a new Flutter project in the admin_pc_app directory, specifically set up for macOS by creating the macos directory and configuring the project accordingly.

```bash
flutter create . --platforms=macos
```

### 4. Configure the project:

#### a. Change the package name (Optional):
You can change the bundle identifier for this macOS app by opening the `macos/Runner.xcworkspace` file in Xcode, selecting the `Runner` project in the left sidebar, and changing the bundle identifier in the `Signing & Capabilities` tab. This is important if you plan to publish your app to the Mac App Store, as the bundle identifier must be unique. But also, it's a good practice to change the bundle identifier to match your project's domain.

For example, `com.example.adminPcApp` may be the default bundle identifier, but you may want to change it to `com.myinstitutionname.euphoniaadminapp` to match your project's bundle identifier, which is important for Firebase configuration. 

#### b. Remove default unwanted files:
You may also delete the default test files that were created by `flutter create .` command. You can do this by running the following command:

```bash
rm -r test
```

Note: it would be great to have tests for the app. For now, we are focusing on the app's core functionality. It would be great if you could contribute by adding tests to the app and submitting a pull request. 🚀

### 5. Configure backend services (Google Firebase):

Make sure you already have a Firebase project set up. If not, follow these general steps, and refer to this [link](https://firebase.google.com/docs/flutter/setup) for more detailed information.

Run the following command to configure Firebase services:

```bash
flutterfire configure
```

- It will ask you which Firebase project you want to use. If you do not have a Firebase project set up, you can create one by selecting the option to create a new project. Otherwise, select the project you want to use.
- Then you will have to choose the platform you want to configure. Select the macOS option.

### 6. Prepare to build the app:

#### a. Add the required permissions:
Set the minimum macOS version in the `macos/Flutter/ephemeral/Flutter-Generated.xcconfig` file. This is the minimum macOS version that the app will support. You can set it to the latest version of macOS that you want to support. For example, if you want to support macOS 10.15 and later, you can set it to `10.15`.

Add the followin to the end of your Podfile:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '10.15'
    end
  end
end
```

Now do the following:
``` bash
flutter pub get
cd macos
pod install
```

#### b. Prepare your system for building the macOS app:

Please follow the instructions in the [official documentation](https://docs.flutter.dev/deployment/macos) to prepare your system for building the macOS app. 

#### c. Update the CocoaPods repository:

If you encounter any issues with the CocoaPods installation, you can try updating the CocoaPods repository by running the following command:

``` bash
cd macos
pod install --repo-update
```

### 7. Run the app:

You can run the app by running the following command:

```bash
cd Euophonia-AI-Reviewer/code/admin_pc_app
bash run_with_config.sh
```

You may also run the app from Xcode by opening the `macos/Runner.xcworkspace` file in Xcode and running the app from there. This will give you more control over the app's configuration and settings. For example, you can change the app's icon, name, and other settings from Xcode. There might be some additional setup required to run the app from Xcode, such as setting up code signing and provisioning profiles. Refer to the [official documentation](https://flutter.dev/desktop#running-your-app) for more information.

Notes:
- The app may take some time to build and run for the first time.
- You may have to run `pod repo update` to update the CocoaPods repository before running the app.
pod install --repo-update



### 7. Build the app:

You can build the app by running the following command:

```bash
flutter build macos
```

# Notes on cybersecurity and privacy:
- We are not responsible for any data breaches or other security incidents that may occur as a result of using this software.
- Do not publish or share the following sensitive files files: `google-services.json`, `GoogleService-Info.plist`, `firebase_options.dart` or others that may contain sensitive information.