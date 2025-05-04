@echo off
setlocal enableextensions enabledelayedexpansion

set DIRNAME=%~dp0
set APP_BASE_NAME=%~n0
set APP_HOME=%DIRNAME%

rem Find java.exe
if defined JAVA_HOME (
    set JAVA_EXE=%JAVA_HOME%\bin\java.exe
) else (
    set JAVA_EXE=java.exe
)

rem Check java exists
"%JAVA_EXE%" -version >NUL 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH.
    echo Please set the JAVA_HOME variable in your environment to match the
    echo location of your Java installation.
    exit /b 1
)

rem Use the correct classpath with proper quoting
set CLASSPATH="%APP_HOME%\gradle\wrapper\gradle-wrapper.jar"

rem Execute Gradle
"%JAVA_EXE%" "-Dorg.gradle.appname=%APP_BASE_NAME%" -classpath %CLASSPATH% org.gradle.wrapper.GradleWrapperMain %*

endlocal
