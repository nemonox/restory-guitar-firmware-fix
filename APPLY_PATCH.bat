@echo off
rem Drag the game folder onto this file, or put this folder inside the game folder and double-click.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0restory_firmware_fix.ps1" %1
pause
