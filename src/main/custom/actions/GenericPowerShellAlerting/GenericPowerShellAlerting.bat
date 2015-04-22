@echo off

rem Some logging that can help troubleshoot
For /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%a-%%b)
For /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set mytime=%%a%%b)
SET LOG=%~d0%~p0GenericPowerShellAlerting.bat.log
echo Called GenericPowerShellAlerting.bat %mydate%_%mytime% >> %LOG%
whoami >> %LOG%

rem http://ss64.com/nt/syntax-replace.html
SET ARGS=%*
echo Arguments list before replacing quotes: >> %LOG%
echo %ARGS% >> %LOG%
rem Can't have &incident= in the URL, replacing & with _
set ARGS=%ARGS:&=_%
rem Replace " with ' in parameter list, since PowerShell treats double-quoted strings with spaces as multiple parameters
set ARGS=%ARGS:"='%
echo Arguments list after replacing: >> %LOG%
echo %ARGS% >> %LOG%

rem Start the PowerShell to do the actual alerting thing
SET PSLOG=%~d0%~p0GenericPowerShellAlerting.ps1.log
powershell.exe -Command "Set-ExecutionPolicy Unrestricted"
powershell.exe -Command %~d0%~p0GenericPowerShellAlerting.ps1 %ARGS% >> %PSLOG%