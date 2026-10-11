@echo off
rem Restores the original Restory.Assembly.dll from the backup (.bak).
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0restory_firmware_fix.ps1" %1 -Restore
pause
