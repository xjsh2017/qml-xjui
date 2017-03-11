echo off
echo.
echo Checking up environment...
set QT_INSTALL_DIR=C:\app\Qt\Qt5.7.1-msvc2013\5.7\msvc2013
set QML_IMPORT_PATH=%QT_INSTALL_DIR%\qml
set PATH=%QT_INSTALL_DIR%\bin;%PATH%
cd /D %QT_INSTALL_DIR%

:Getting BAT run directory
cd /d %~dp0
set BAT_FILE_DIR=%cd%

echo.
echo Starting to run demo....

if "%1" == "h" goto begin 
mshta vbscript:createobject("wscript.shell").run("""%~fnx0"" h",0)(window.close)&&exit 
:begin

qmlscene -I %QML_IMPORT_PATH% %BAT_FILE_DIR%/main.qml
