@echo off
echo Running build_runner to generate Freezed models...
flutter pub run build_runner build --delete-conflicting-outputs
echo Done! 