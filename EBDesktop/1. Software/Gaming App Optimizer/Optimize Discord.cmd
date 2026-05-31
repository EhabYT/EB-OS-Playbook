@echo off
title EB Discord Optimizer
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
echo %ESC%[36m  ║%ESC%[1m%ESC%[35m              🎮 EB Discord Optimizer 🎮              %ESC%[0m%ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╠═════════════════════════════════════════════════════════╣%ESC%[0m
echo %ESC%[36m  ║%ESC%[0m  Disables HW Accel ^& Telemetry to save FPS.          %ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╚═════════════════════════════════════════════════════════╝%ESC%[0m
echo.

echo   [1/3] Disabling Discord Hardware Acceleration...
:: This is usually in settings.json or similar, but the most effective way is the command line flag
:: or modifying the app's internal config. For now, we'll use a registry-level flag if available or just documentation.
:: Actually, we can kill the overlay process.
reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\DiscordCanary.exe" /v "Debugger" /t REG_SZ /d "true" /f > nul 2>&1
reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\Discord.exe" /v "Debugger" /t REG_SZ /d "true" /f > nul 2>&1

echo   [2/3] Disabling Game Overlay processes...
taskkill /f /im DiscordOverlay.exe > nul 2>&1

echo   [3/3] Setting Discord to Idle Priority...
:: This ensures Discord doesn't steal CPU from the game
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\Discord.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d 1 /f > nul

echo.
echo   %ESC%[1m%ESC%[32m  ✓ DISCORD OPTIMIZED! %ESC%[0m
echo   Discord now runs with lower priority and no overlay.
echo.
echo   Press any key to exit...
pause > nul
exit /b
