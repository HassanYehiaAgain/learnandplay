@echo off
echo Building Android app...

cd "%~dp0"
echo Current directory: %CD%

echo Setting up environment...
call flutter clean

echo Copying fixed Gradle wrapper...
copy /Y "android\gradlew-fixed.bat" "android\gradlew.bat"

echo Building APK...
call flutter build apk --verbose

echo Build completed.
pause 