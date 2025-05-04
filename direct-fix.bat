@echo off
echo Fixing Android build issues...

cd /d "C:\Users\hassa\Desktop\Learn & Play\learnandplay"
echo Current directory: %CD%

echo Creating gradle wrapper directory...
if not exist "android\gradle\wrapper" mkdir "android\gradle\wrapper"

echo Downloading gradle-wrapper.jar...
powershell -Command "$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri 'https://github.com/gradle/gradle/raw/v7.5.0/gradle/wrapper/gradle-wrapper.jar' -OutFile 'android\gradle\wrapper\gradle-wrapper.jar'"

echo Creating gradle-wrapper.properties...
echo distributionBase=GRADLE_USER_HOME > "android\gradle\wrapper\gradle-wrapper.properties"
echo distributionPath=wrapper/dists >> "android\gradle\wrapper\gradle-wrapper.properties"
echo zipStoreBase=GRADLE_USER_HOME >> "android\gradle\wrapper\gradle-wrapper.properties"
echo zipStorePath=wrapper/dists >> "android\gradle\wrapper\gradle-wrapper.properties"
echo distributionUrl=https\://services.gradle.org/distributions/gradle-7.5-all.zip >> "android\gradle\wrapper\gradle-wrapper.properties"

echo Creating fixed gradlew.bat...
echo @echo off > "android\gradlew.bat"
echo setlocal enabledelayedexpansion >> "android\gradlew.bat"
echo. >> "android\gradlew.bat"
echo set DIRNAME=%%~dp0 >> "android\gradlew.bat"
echo set APP_BASE_NAME=%%~n0 >> "android\gradlew.bat"
echo set APP_HOME=%%DIRNAME%% >> "android\gradlew.bat"
echo. >> "android\gradlew.bat"
echo rem Find java.exe >> "android\gradlew.bat"
echo if defined JAVA_HOME ( >> "android\gradlew.bat"
echo     set JAVA_EXE=%%JAVA_HOME%%\bin\java.exe >> "android\gradlew.bat"
echo ) else ( >> "android\gradlew.bat"
echo     set JAVA_EXE=java.exe >> "android\gradlew.bat"
echo ) >> "android\gradlew.bat"
echo. >> "android\gradlew.bat"
echo "%%JAVA_EXE%%" -version ^>NUL 2^>^&1 >> "android\gradlew.bat"
echo if %%ERRORLEVEL%% neq 0 ( >> "android\gradlew.bat"
echo     echo ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH. >> "android\gradlew.bat"
echo     echo Please set the JAVA_HOME variable in your environment to match the >> "android\gradlew.bat"
echo     echo location of your Java installation. >> "android\gradlew.bat"
echo     exit /b 1 >> "android\gradlew.bat"
echo ) >> "android\gradlew.bat"
echo. >> "android\gradlew.bat"
echo set CLASSPATH="%%APP_HOME%%\gradle\wrapper\gradle-wrapper.jar" >> "android\gradlew.bat"
echo. >> "android\gradlew.bat"
echo "%%JAVA_EXE%%" "-Dorg.gradle.appname=%%APP_BASE_NAME%%" -classpath %%CLASSPATH%% org.gradle.wrapper.GradleWrapperMain %%* >> "android\gradlew.bat"
echo. >> "android\gradlew.bat"
echo endlocal >> "android\gradlew.bat"

echo Verifying files...
dir "android\gradle\wrapper"

echo.
echo Android build fixed. Now you can run:
echo flutter build apk --no-tree-shake-icons
echo.
echo Press any key to run the build command...
pause > nul

echo Running Flutter build...
flutter build apk --no-tree-shake-icons

echo.
echo Done.
pause 