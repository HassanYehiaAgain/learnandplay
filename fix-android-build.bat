@echo off
echo Fixing Android build issues...

cd /d "%~dp0"
echo Current directory: %CD%

echo Creating gradle wrapper directory...
if not exist "android\gradle\wrapper" mkdir "android\gradle\wrapper"

echo Downloading gradle-wrapper.jar...
powershell -Command "if (!(Test-Path 'android\gradle\wrapper\gradle-wrapper.jar')) { Invoke-WebRequest -Uri 'https://github.com/gradle/gradle/raw/v7.5.0/gradle/wrapper/gradle-wrapper.jar' -OutFile 'android\gradle\wrapper\gradle-wrapper.jar' }"

echo Ensuring gradle-wrapper.properties is correct...
echo distributionBase=GRADLE_USER_HOME> "android\gradle\wrapper\gradle-wrapper.properties"
echo distributionPath=wrapper/dists>> "android\gradle\wrapper\gradle-wrapper.properties"
echo zipStoreBase=GRADLE_USER_HOME>> "android\gradle\wrapper\gradle-wrapper.properties"
echo zipStorePath=wrapper/dists>> "android\gradle\wrapper\gradle-wrapper.properties"
echo distributionUrl=https\://services.gradle.org/distributions/gradle-7.5-all.zip>> "android\gradle\wrapper\gradle-wrapper.properties"

echo Creating fixed gradlew.bat...
(
echo @echo off
echo setlocal enableextensions enabledelayedexpansion
echo.
echo set DIRNAME=%%~dp0
echo set APP_BASE_NAME=%%~n0
echo set APP_HOME=%%DIRNAME%%
echo.
echo rem Find java.exe
echo if defined JAVA_HOME ^(
echo     set JAVA_EXE=%%JAVA_HOME%%\bin\java.exe
echo ^) else ^(
echo     set JAVA_EXE=java.exe
echo ^)
echo.
echo rem Check java exists
echo "%%JAVA_EXE%%" -version ^>NUL 2^>^&1
echo if %%ERRORLEVEL%% neq 0 ^(
echo     echo ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH.
echo     echo Please set the JAVA_HOME variable in your environment to match the
echo     echo location of your Java installation.
echo     exit /b 1
echo ^)
echo.
echo rem Use the correct classpath with proper quoting
echo set CLASSPATH="%%APP_HOME%%\gradle\wrapper\gradle-wrapper.jar"
echo.
echo rem Execute Gradle
echo "%%JAVA_EXE%%" "-Dorg.gradle.appname=%%APP_BASE_NAME%%" -classpath %%CLASSPATH%% org.gradle.wrapper.GradleWrapperMain %%*
echo.
echo endlocal
) > "android\gradlew-fixed.bat"

echo Backing up original gradlew.bat...
if exist "android\gradlew.bat.original" (
  echo Original backup already exists.
) else (
  copy /Y "android\gradlew.bat" "android\gradlew.bat.original"
)

echo Replacing gradlew.bat with fixed version...
copy /Y "android\gradlew-fixed.bat" "android\gradlew.bat"

echo.
echo Android build fixed. Now you can run:
echo flutter build apk
echo.
echo If you want to build from this script, press any key to continue...
pause > nul

echo Running flutter build apk...
flutter build apk

echo Done.
pause 