@echo off

rem Some logging that can help troubleshoot
For /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c%%a%%b)
For /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set mytime=%%a%%b)
SET LOG=%~d0%~p0GenericPowerShellAlerting.bat.log
echo Called GenericPowerShellAlerting.bat %mydate%_%mytime% >> %LOG%
echo Called script as: >> %LOG%
whoami >> %LOG%
echo Parameters: >> %LOG%
echo %* >> %LOG%

rem Start the PowerShell to do the actual alerting
SET PSLOG="%~d0%~p0GenericPowerShellAlerting.ps1.%mydate%-%mytime%.log"
powershell.exe -Command "Set-ExecutionPolicy Unrestricted"
powershell.exe -File "%~d0%~p0GenericPowerShellAlerting.ps1" %* >> %PSLOG%