# Connectify - Real-time Chat Application

Connectify is a modern, cross-platform chat application built with Flutter. It enables users to connect, search for others, and engage in real-time messaging conversations. The app leverages Firebase for secure authentication and Firestore for real-time data synchronization, ensuring a seamless experience across Android, iOS, web, and desktop.

## Features

- **User Authentication**: Secure sign-up and sign-in with email/password, including profile creation with name and mobile number.
- **User Search**: Real-time search for other users to start conversations.
- **Real-time Messaging**: Send, receive, edit, and delete messages in private chats with timestamps.
- **Adaptive Theme**: Support for light and dark modes with Material 3 design.
- **Profile Management**: View user profile and settings, including theme toggle and logout.

## Prerequisites

- Flutter SDK (version 3.7.0 or higher)
- Firebase project with Authentication and Firestore enabled
- Android/iOS setup (for mobile builds)
- Dart SDK (included with Flutter)

## Installation

1. **Clone the Repository**:
   ```
   git clone https://github.com/Yashika004/connectify
   cd connectify
   ```

2. **Install Dependencies**:
   ```
   flutter pub get
   ```

3. **Firebase Setup**:
   - Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com).
   - Enable Authentication (Email/Password) and Firestore Database.
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) and place them in the respective directories (`android/app/` and `ios/Runner/`).
   - For web/desktop, add Firebase config to the app (see Firebase docs).

4. **Firestore Rules**:
   Ensure Firestore security rules allow authenticated reads/writes for users and chats. Example basic rules:
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
       match /chats/{chatId} {
         allow read, write: if request.auth != null;
       }
       match /messages/{messageId} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

## Running the App

1. **Connect a Device/Emulator**:
   - For Android: `flutter devices` to list, then run on selected.
   - For iOS: Open in Xcode if needed.
   - For web: `flutter run -d chrome`.

2. **Build and Run**:
   ```
   flutter run
   ```

The app will initialize Firebase, check authentication status, and route to the auth screen if not logged in, or the home screen if authenticated.

## Project Structure

- `lib/main.dart`: App entry point with theme setup and routing.
- `lib/screens/`: UI screens (auth_screen.dart, chat_screen.dart).
- `lib/mainscreen/`: Main app screens (homeScreen.dart, settingsScreen.dart).
- `lib/services/`: Backend services (auth_service.dart, firestore_service.dart).
- `assets/images/`: Static assets like user icons.

## Tech Stack

- **Frontend**: Flutter (Dart), Material 3, Google Fonts (Poppins), Adaptive Theme.
- **Backend**: Firebase Authentication, Cloud Firestore.
- **Dependencies**: firebase_core, firebase_auth, cloud_firestore, google_fonts, adaptive_theme.

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request for any improvements, bug fixes, or new features.

1. Fork the project.
2. Create a feature branch (`git checkout -b feature/AmazingFeature`).
3. Commit changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the branch (`git push origin feature/AmazingFeature`).
5. Open a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

*(Note: Add a LICENSE file if not present.)*

For questions or issues, open a GitHub issue.
