@echo off
echo Downloading Gradle wrapper JAR file...
powershell -Command "Invoke-WebRequest -Uri 'https://github.com/gradle/gradle/raw/v7.5.0/gradle/wrapper/gradle-wrapper.jar' -OutFile 'android\gradle\wrapper\gradle-wrapper.jar'"
echo Download complete. 