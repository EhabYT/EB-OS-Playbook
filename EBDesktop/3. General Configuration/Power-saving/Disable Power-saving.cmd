@echo off
title EB Power-Saving Manager
chcp 65001 > nul
for /f %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"

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
echo %ESC%[36m  ║%ESC%[1m%ESC%[33m            ⚡ EB Power-Saving Manager ⚡             %ESC%[0m%ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╠═════════════════════════════════════════════════════════╣%ESC%[0m
echo %ESC%[36m  ║%ESC%[0m  Disabling aggressive energy saving features.        %ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╚═════════════════════════════════════════════════════════╝%ESC%[0m
echo.

set "script=%windir%\EBModules\Scripts\ScriptWrappers\DisablePowerSaving.ps1"
if not exist "%script%" (
    echo   %ESC%[31m✗ Core module not found!%ESC%[0m
    pause
    exit /b 1
)

echo   [1/1] Applying Power-Saving Disable...
powershell -EP Bypass -NoP -File "%script%" %*

echo.
echo   %ESC%[1m%ESC%[32m  ✓ POWER-SAVING DISABLED! %ESC%[0m
echo.
echo   Press any key to exit...
pause > nul
exit /b
