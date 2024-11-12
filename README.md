# Video Conference App

A powerful and user-friendly video conferencing app built with Flutter, Dart, Firebase, and ZegoCloud. This app offers seamless video and audio calls, alongside a robust chat functionality, providing an optimized, high-quality experience for enhanced collaboration and connectivity.

## ✨ Key Features

- **High-Quality Video & Audio Calls**: Enjoy smooth, high-definition video and crystal-clear audio, powered by ZegoCloud, ensuring reliable, real-time communication.
- **In-App Real-Time Chat**: Exchange messages during calls or as a standalone feature, creating a collaborative experience within the app.
- **Firebase Integration**: Secure user authentication and data storage with Firebase Authentication and Firestore for real-time data management and privacy.
- **Responsive Flutter UI**: A modern, intuitive interface built with Flutter, designed for a smooth experience on both iOS and Android.
- **Efficient State Management**: Streamlined app state management using Provider, ensuring consistent performance and maintainable code.

## 🚀 Getting Started

### Prerequisites

Ensure Flutter is installed and configured. Follow the [Flutter installation guide](https://flutter.dev/docs/get-started/install) if needed.

### Installation

1. **Clone the repository**:

    ```bash
    git clone https://github.com/yourusername/video_conference_app.git
    cd video_conference_app
    ```

2. **Install dependencies**:

    ```bash
    flutter pub get
    ```

### Configuration

#### Firebase Setup

1. Set up Firebase for Authentication and Firestore by following [Firebase’s Flutter documentation](https://firebase.google.com/docs/flutter/setup).
2. Download `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS), and place them in the appropriate directories within your project.

#### ZegoCloud Setup

1. Sign up at [ZegoCloud](https://www.zegocloud.com/) and create a new project.
2. Retrieve your **App ID** and **App Secret** from ZegoCloud, and add them to your project configuration.

#### Environment Variables

To keep your credentials secure, create a `lib/config.dart` file or use environment-specific files for Firebase and ZegoCloud configurations.

## 📱 Usage

To run the app on an emulator or a physical device:

```bash
flutter run
```
## 📂 Core Screens and Functionalities

- **Home Screen**: View a list of active users and available meetings.
- **Chat Screen**: Real-time messaging with media-sharing options.
- **Video/Audio Call Screen**: Start or join calls, toggle between video/audio modes, and access mute/unmute options.
- **Profile and Settings**: Update user profiles, adjust app settings, and view meeting history.

## 📦 Dependencies

This project uses the following core packages:

- **Flutter SDK**: Framework for app structure and UI
- **Firebase Authentication**: Manages user login and registration
- **Firebase Firestore**: Real-time database functionality
- **ZegoCloud SDK**: Enables video and audio call functionality
- **Provider**: Supports efficient state management

## ⚖️ License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## 📧 Support

For any issues, questions, or feature requests, please contact [arpit.vekariya123@gmail.com].
