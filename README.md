# Chatter Plus


## Project Screen Shrot

![Frame 10](https://github.com/user-attachments/assets/7c9de886-2686-4af3-8e1a-fb8f81917c52)



Chatter Plus is a Flutter-based chat application that enables users to communicate in real-time. The app features user authentication, message notifications via Firebase Cloud Messaging, and supports light and dark themes.

## Features

- **User Authentication**: Sign up and log in using Firebase Authentication.
- **Real-Time Chat**: Send and receive messages instantly.
- **Push Notifications**: Get notified of new messages even when the app is in the background.
- **Light/Dark Theme**: Switch between light and dark themes easily.
- **Firebase Integration**: Utilizes Firebase for backend services.

## Technologies Used

- Flutter
- Firebase (Authentication, Cloud Messaging)
- Provider (State Management)
- Dart

## Prerequisites

Make sure you have the following installed on your machine:

- Flutter SDK
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Firebase account (to set up Firebase project)


## Folder Structure

```plaintext
chatter_plus/
│
├── lib/
│   ├── helpers/         # Helper classes for local storage and notifications
│   ├── pages/           # UI Pages for the app
│   ├── providers/       # Providers for state management
│   ├── main.dart        # Entry point of the application
│   └── firebase_options.dart  # Firebase configuration options
│
├── android/             # Android platform files
├── ios/                 # iOS platform files
└── pubspec.yaml         # Project dependencies

