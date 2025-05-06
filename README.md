# Learn & Play

An educational gaming platform for teachers and students.

## Features

- Teacher dashboard for creating and managing educational games
- Student dashboard for playing games and tracking progress
- Multiple game templates: true/false, drag & drop, matching, etc.
- Real-time analytics for teachers

## Setup

1. Install Flutter (version 3.6.0 or higher)
2. Clone the repository
3. Run `flutter pub get` to install dependencies
4. Run `flutter pub run build_runner build --delete-conflicting-outputs` to generate Freezed model files
5. Connect Firebase services
6. Run the app with `flutter run`

## Firebase Configuration

This app requires Firebase services:
- Authentication
- Firestore Database
- (Optional) Analytics

## Models

The app uses Freezed for immutable models and JSON serialization:

- **AppUser**: User data model with roles (teacher/student)
- **Game**: Game template data with various question types
- **GameCompletion**: Records of completed games with scores

## Building

To generate the Freezed models after making changes:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
