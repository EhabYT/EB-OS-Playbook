@echo off
title EB Browser Optimizer
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
echo %ESC%[36m  ║%ESC%[1m%ESC%[34m              🌐 EB Browser Optimizer 🌐              %ESC%[0m%ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╠═════════════════════════════════════════════════════════╣%ESC%[0m
echo %ESC%[36m  ║%ESC%[0m  Disables HW Accel to prevent in-game stutters.      %ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╚═════════════════════════════════════════════════════════╝%ESC%[0m
echo.

echo   [1/2] Disabling Chrome Hardware Acceleration...
reg add "HKCU\Software\Policies\Google\Chrome" /v "HardwareAccelerationModeEnabled" /t REG_DWORD /d 0 /f > nul 2>&1

echo   [2/2] Disabling Edge Hardware Acceleration...
reg add "HKCU\Software\Policies\Microsoft\Edge" /v "HardwareAccelerationModeEnabled" /t REG_DWORD /d 0 /f > nul 2>&1

echo.
echo   %ESC%[1m%ESC%[32m  ✓ BROWSERS OPTIMIZED! %ESC%[0m
echo   Hardware acceleration is now disabled for Chrome and Edge.
echo.
echo   Press any key to exit...
pause > nul
exit /b
