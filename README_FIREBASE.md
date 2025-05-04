# Firebase Backend Setup for Learn & Play

This document provides instructions for setting up and deploying the Firebase backend for the Learn & Play educational platform.

## Required Firebase Services

The application uses the following Firebase services:
- **Firebase Authentication**: For user authentication (teachers and students)
- **Cloud Firestore**: For storing application data (users, courses, games, progress)
- **Firebase Storage**: For storing media assets (profile images, game assets)
- **Firebase Hosting** (optional): For deploying the web version

## Prerequisites

1. Install Firebase CLI:
```bash
npm install -g firebase-tools
```

2. Log in to Firebase:
```bash
firebase login
```

3. Initialize Firebase in your project directory (if not already done):
```bash
firebase init
```

## Security Rules Deployment

The repository includes security rules for both Firestore and Storage. To deploy them:

```bash
# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Storage rules
firebase deploy --only storage:rules
```

## Firestore Database Setup

The application requires the following collections:

1. **users**: Stores user profiles
2. **subjects**: Stores subject/class information
3. **educational_games**: Stores educational games created by teachers  
4. **game_progress**: Tracks student progress on games
5. **app_settings**: Application-wide settings
6. **badges**: Badge definitions for gamification
7. **analytics**: Usage analytics
8. **user_activity**: User activity logs

You can create these collections manually or they will be created when the app first writes to them.

## Firestore Indexes

The application requires several compound indexes for efficient queries. Deploy the indexes with:

```bash
firebase deploy --only firestore:indexes
```

## Firebase Authentication Setup

1. In the Firebase Console, go to Authentication
2. Enable the Email/Password provider
3. (Optional) Enable Google Sign-In for easier authentication

## Initial Data Setup

You may want to set up some initial data:

1. Create an admin user with teacher role
2. Create some initial subjects
3. Create some sample educational games

You can use the Firebase Console or run a script to do this.

## Firebase Storage Structure

The storage follows this structure:
- `/users/{userId}/profile/` - User profile images
- `/games/{gameId}/{assetType}/` - Game assets (images, audio)
- `/subjects/{subjectId}/` - Subject materials
- `/public/` - Public assets

## Environment Configuration

Make sure your Flutter app is configured with the correct Firebase project by running:

```bash
flutterfire configure
```

This will update the `firebase_options.dart` file with your project-specific settings.

## Testing Locally

To test with local Firebase emulators:

```bash
firebase emulators:start
```

Then modify your code to connect to the emulators:

```dart
// In your initialization code
if (kDebugMode) {
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  // Add other emulators as needed
}
```

## Production Deployment

When ready to deploy to production:

1. Make sure all security rules are properly set
2. Double-check all indexes are created
3. Enable necessary Firebase services in the billing section
4. Consider setting up Firebase Analytics for usage tracking
5. Set up Firebase Crashlytics for error reporting

## Troubleshooting

- If authentication fails, check your Firebase project settings and API keys
- If database operations fail, verify your security rules allow the operations
- Use Firebase Console logs to debug issues

## Further Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/docs/overview)
- [Firebase Security Rules](https://firebase.google.com/docs/rules) 