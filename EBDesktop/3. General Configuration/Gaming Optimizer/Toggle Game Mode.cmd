@echo off
title EB Game Mode Toggle
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
echo %ESC%[36m  ║%ESC%[1m%ESC%[33m             🎮 EB Game Mode Toggle 🎮              %ESC%[0m%ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╠═════════════════════════════════════════════════════════╣%ESC%[0m
echo %ESC%[36m  ║%ESC%[0m  Checks and Toggles Windows Game Mode status.        %ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╚═════════════════════════════════════════════════════════╝%ESC%[0m
echo.

for /f "tokens=3" %%a in ('reg query "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" 2^>nul') do set "status=%%a"

if "%status%"=="0x1" (
    echo   Current Status: %ESC%[32mENABLED%ESC%[0m
    choice /m "  Disable Game Mode? "
    if errorlevel 2 exit /b
    reg add "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d 0 /f > nul
    echo   %ESC%[31m✓ Game Mode Disabled.%ESC%[0m
) else (
    echo   Current Status: %ESC%[31mDISABLED%ESC%[0m
    choice /m "  Enable Game Mode? "
    if errorlevel 2 exit /b
    reg add "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d 1 /f > nul
    echo   %ESC%[32m✓ Game Mode Enabled.%ESC%[0m
)

echo.
echo   Press any key to exit...
pause > nul
exit /b
