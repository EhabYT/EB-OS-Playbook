@echo off
title EB OBS Frame Drop Fixer
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
echo %ESC%[36m  ║%ESC%[1m%ESC%[35m             📡 EB OBS Frame Drop Fixer 📡             %ESC%[0m%ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╠═════════════════════════════════════════════════════════╣%ESC%[0m
echo %ESC%[36m  ║%ESC%[0m  Fixes network-related dropped frames in OBS.        %ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╚═════════════════════════════════════════════════════════╝%ESC%[0m
echo.

echo   [1/3] Tuning TCP Send Window for RTMP...
netsh interface tcp set global autotuninglevel=normal > nul
netsh interface tcp set global rss=enabled > nul

echo   [2/3] Disabling Network Throttling...
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 0xFFFFFFFF /f > nul

echo   [3/3] Resetting Network Stack...
ipconfig /release > nul
ipconfig /renew > nul
ipconfig /flushdns > nul

echo.
echo   %ESC%[1m%ESC%[32m  ✓ NETWORK OPTIMIZED FOR STREAMING! %ESC%[0m
echo   If you still drop frames, check your bitrate in OBS.
echo.
echo   Press any key to exit...
pause > nul
exit /b
