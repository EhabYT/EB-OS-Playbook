@echo off
title EB Audio Fixer (Sync ^& Glitch Fix)
chcp 65001 > nul
for /f %%a in ('forfiles /m "%~nx0" /c "cmd /c echo 0x1B"') do set "ESC=%%a"

set "___args="%~f0" %*"
fltmc > nul 2>&1 || (
    echo Administrator privileges are required.
    powershell -c "Start-Process -Verb RunAs -FilePath 'cmd' -ArgumentList """/c $env:___args"""" 2> nul || (
        echo You must run this script as admin.
        if "%*"=="" pause
        exit /b 1
    )
    exit /b
)

mode con: cols=65 lines=20
cls

echo.
echo %ESC%[36m  ╔═════════════════════════════════════════════════════════╗%ESC%[0m
echo %ESC%[36m  ║%ESC%[1m%ESC%[33m            🔊 EB Audio Sync ^& Glitch Fix 🔊            %ESC%[0m%ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╠═════════════════════════════════════════════════════════╣%ESC%[0m
echo %ESC%[36m  ║%ESC%[0m  Restarts audio services to fix desync and crackling.  %ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╚═════════════════════════════════════════════════════════╝%ESC%[0m
echo.

echo   [1/3] Stopping Windows Audio services...
net stop AudioEndpointBuilder /y > nul 2>&1
net stop AudioSrv /y > nul 2>&1

echo   [2/3] Clearing Audio Cache...
powershell -c "Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Render\*' -ErrorAction SilentlyContinue" > nul 2>&1

echo   [3/3] Restarting Audio services...
net start AudioSrv > nul 2>&1
net start AudioEndpointBuilder > nul 2>&1

echo.
echo   %ESC%[1m%ESC%[32m  ✓ AUDIO SERVICES RESTARTED! %ESC%[0m
echo   Check your OBS/Game audio sync now.
echo.
echo   Press any key to exit...
pause > nul
exit /b
