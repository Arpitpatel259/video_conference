# Video Conference App

A unique video conferencing app built with Flutter, Dart, Firebase, and ZegoCloud, providing users with seamless audio and video calling, as well as chat functionality. The app is designed to enhance collaboration and connection with an intuitive, high-quality user experience.

## Key Features

- **Video and Audio Calls**: Engage in high-definition video and crystal-clear audio calls powered by ZegoCloud, allowing for seamless communication between users.
- **Real-time Chat**: Built-in chat functionality enables users to message each other within the app, creating a collaborative experience during calls and conferences.
- **Firebase Integration**: Utilizes Firebase Authentication for user login and registration, and Firestore for secure, real-time data storage.
- **Flutter UI**: Clean, user-friendly UI design created using Flutter, with a focus on smooth and responsive interactions for both iOS and Android.
- **State Management**: Efficient state management with providers for reactive and manageable code.

## Installation

To get started, clone the repository and install the required dependencies.

```bash
git clone https://github.com/yourusername/video_conference_app.git
cd video_conference_app
flutter pub get

Configuration
Firebase Setup:

Set up Firebase for authentication and Firestore database.
Download google-services.json (for Android) and GoogleService-Info.plist (for iOS) and add them to your project.
ZegoCloud Setup:

Sign up on ZegoCloud and create a project.
Obtain the App ID and App Secret from ZegoCloud and add them to your project's configuration files.
Environment Variables:

Add Firebase and ZegoCloud configurations to lib/config.dart or use environment-specific files to keep credentials secure.
Usage
Starting the App
To run the app on an emulator or physical device:

bash
Copy code
flutter run
Core Screens and Functionalities
Home Screen: View a list of active users and available meetings.
Chat Screen: Real-time messaging and media sharing.
Video/Audio Call Screen: Start or join calls, switch between video and audio modes, and mute/unmute options.
Profile and Settings: Update profile details, manage app settings, and view meeting history.
Dependencies
This project relies on several core Flutter and Firebase packages:

Flutter SDK for app structure and UI
Firebase Authentication for user login and registration
Firebase Firestore for real-time database functionality
ZegoCloud SDK for video and audio call functionality
Provider for state management
License
This project is licensed under the MIT License. See the LICENSE file for more details.

Support
For issues or feature requests, please contact [your email address].
