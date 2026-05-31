@echo off
title EB HPET Timer Fix
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
echo %ESC%[36m  ║%ESC%[1m%ESC%[33m               ⏱️  EB HPET Timer Fix ⏱️                %ESC%[0m%ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╠═════════════════════════════════════════════════════════╣%ESC%[0m
echo %ESC%[36m  ║%ESC%[0m  Manages High Precision Event Timer status.           %ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╚═════════════════════════════════════════════════════════╝%ESC%[0m
echo.

bcdedit /enum | findstr /i "useplatformclock" > nul
if %errorlevel%==0 (
    echo   Current Status: %ESC%[32mFORCED ON%ESC%[0m
    choice /m "  Disable HPET (Recommended for lower latency)? "
    if errorlevel 2 exit /b
    bcdedit /deletevalue useplatformclock > nul 2>&1
    bcdedit /set disabledynamictick yes > nul 2>&1
    echo   %ESC%[31m✓ HPET Disabled in Windows.%ESC%[0m
) else (
    echo   Current Status: %ESC%[31mDISABLED / DEFAULT%ESC%[0m
    choice /m "  Force Enable HPET (Not recommended)? "
    if errorlevel 2 exit /b
    bcdedit /set useplatformclock yes > nul 2>&1
    echo   %ESC%[32m✓ HPET Force-Enabled.%ESC%[0m
)

echo.
echo   %ESC%[33mRESTART REQUIRED for changes to apply.%ESC%[0m
echo.
echo   Press any key to exit...
pause > nul
exit /b
