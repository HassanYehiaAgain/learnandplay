@echo off
setlocal enabledelayedexpansion

echo Fixing Android build issues...

echo Detecting current path...
set SCRIPT_DIR=%~dp0
set SCRIPT_DIR=%SCRIPT_DIR:~0,-1%
echo Current directory: "%SCRIPT_DIR%"

echo Creating gradle wrapper directory...
if not exist "%SCRIPT_DIR%\android\gradle\wrapper" mkdir "%SCRIPT_DIR%\android\gradle\wrapper"

echo Downloading gradle-wrapper.jar...
powershell -Command "$ProgressPreference = 'SilentlyContinue'; if (!(Test-Path '%SCRIPT_DIR%\android\gradle\wrapper\gradle-wrapper.jar')) { Invoke-WebRequest -Uri 'https://github.com/gradle/gradle/raw/v7.5.0/gradle/wrapper/gradle-wrapper.jar' -OutFile '%SCRIPT_DIR%\android\gradle\wrapper\gradle-wrapper.jar' }"

echo Ensuring gradle-wrapper.properties is correct...
(
echo distributionBase=GRADLE_USER_HOME
echo distributionPath=wrapper/dists
echo zipStoreBase=GRADLE_USER_HOME
echo zipStorePath=wrapper/dists
echo distributionUrl=https\://services.gradle.org/distributions/gradle-7.5-all.zip
) > "%SCRIPT_DIR%\android\gradle\wrapper\gradle-wrapper.properties"

echo Creating fixed gradlew.bat...
(
echo @echo off
echo setlocal enabledelayedexpansion
echo.
echo set DIRNAME=%%~dp0
echo set APP_BASE_NAME=%%~n0
echo set APP_HOME=%%DIRNAME%%
echo.
echo rem Find java.exe
echo if defined JAVA_HOME ^(
echo     set JAVA_EXE="%%JAVA_HOME%%\bin\java.exe"
echo ^) else ^(
echo     set JAVA_EXE=java.exe
echo ^)
echo.
echo rem Check java exists
echo %%JAVA_EXE%% -version ^>NUL 2^>^&1
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
echo %%JAVA_EXE%% -Dorg.gradle.appname=%%APP_BASE_NAME%% -classpath %%CLASSPATH%% org.gradle.wrapper.GradleWrapperMain %%*
echo.
echo endlocal
) > "%SCRIPT_DIR%\android\gradlew-fixed.bat"

echo Backing up original gradlew.bat...
if exist "%SCRIPT_DIR%\android\gradlew.bat.original" (
  echo Original backup already exists.
) else (
  copy /Y "%SCRIPT_DIR%\android\gradlew.bat" "%SCRIPT_DIR%\android\gradlew.bat.original"
)

echo Replacing gradlew.bat with fixed version...
copy /Y "%SCRIPT_DIR%\android\gradlew-fixed.bat" "%SCRIPT_DIR%\android\gradlew.bat"

echo Creating local.properties if missing...
if not exist "%SCRIPT_DIR%\android\local.properties" (
  echo Creating local.properties with SDK path...
  (
  echo sdk.dir=C:\\Users\\hassa\\AppData\\Local\\Android\\sdk
  echo flutter.sdk=C:\\Users\\hassa\\flutter
  echo flutter.buildMode=debug
  echo flutter.versionName=1.0.0
  echo flutter.versionCode=1
  ) > "%SCRIPT_DIR%\android\local.properties"
)

echo.
echo Android build fixed. Now you can run the following command from your project root:
echo.
echo flutter build apk --no-tree-shake-icons
echo.
echo If you want to continue building from this script, press any key...
pause > nul

echo Running build from a temporary batch file to avoid path issues...
(
echo @echo off
echo cd /d "%SCRIPT_DIR%"
echo flutter build apk --no-tree-shake-icons
) > "%SCRIPT_DIR%\temp_build.bat"

"%SCRIPT_DIR%\temp_build.bat"

echo Cleaning up...
if exist "%SCRIPT_DIR%\temp_build.bat" del "%SCRIPT_DIR%\temp_build.bat"

echo Done.
echo Press any key to exit...
pause > nul
endlocal 