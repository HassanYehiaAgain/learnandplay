# Learn, Play, Level Up - Flutter Version

This is a Flutter implementation of the Learn, Play, Level Up React web application. The app provides an educational gaming platform for students and teachers, featuring interactive gameplay and progress tracking.

## Features

- Interactive educational games
- Student and teacher dashboards
- Game creation tools for teachers
- Progress tracking and achievement awards
- Responsive design for mobile and desktop

## Getting Started

### Prerequisites

- Flutter SDK (version 3.19.0 or higher)
- Dart SDK (version 3.3.0 or higher)
- Android Studio / VS Code with Flutter plugins
- Android Emulator / iOS Simulator for mobile testing

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/learn_play_level_up_flutter.git
   cd learn_play_level_up_flutter
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

   For web deployment:
   ```bash
   flutter run -d chrome
   ```

### Building for Production

To build a release version of the app:

```bash
# For Android
flutter build apk --release

# For iOS
flutter build ios --release

# For web
flutter build web --release
```

## Project Structure

- `lib/` - Contains all Dart code
  - `components/` - Reusable UI components
  - `models/` - Data models
  - `pages/` - Application screens
  - `services/` - API and backend services
  - `theme/` - App theme and styling
  - `utils/` - Utility functions

## Technology Stack

- **Flutter** - UI framework
- **Provider & Riverpod** - State management
- **Go Router** - Navigation and routing
- **Dio/Http** - API communication
- **Google Fonts** - Typography
- **Flutter Hooks** - Stateful logic

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Original React app by Lovable.dev
- Flutter team for the amazing framework
