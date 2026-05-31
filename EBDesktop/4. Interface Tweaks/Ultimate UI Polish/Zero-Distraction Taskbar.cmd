@echo off
title EB Zero-Distraction Taskbar
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
echo %ESC%[36m  ║%ESC%[1m%ESC%[34m           🖥️  EB Zero-Distraction Taskbar 🖥️            %ESC%[0m%ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╠═════════════════════════════════════════════════════════╣%ESC%[0m
echo %ESC%[36m  ║%ESC%[0m  Toggles taskbar auto-hide for zero distraction.     %ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╚═════════════════════════════════════════════════════════╝%ESC%[0m
echo.

:: Get current state from binary registry value
powershell -c "$val = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3').Settings; if ($val[8] -eq 3) { $val[8] = 2; Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3' -Name 'Settings' -Value $val; echo 'OFF' } else { $val[8] = 3; Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3' -Name 'Settings' -Value $val; echo 'ON' }" | findstr "ON" > nul

if %errorlevel%==0 (
    echo   %ESC%[32m✓ Taskbar Auto-Hide ENABLED.%ESC%[0m
) else (
    echo   %ESC%[31m✓ Taskbar Auto-Hide DISABLED.%ESC%[0m
)

echo.
echo   Restarting Explorer to apply changes...
taskkill /f /im explorer.exe > nul
start explorer.exe
echo.
echo   Press any key to exit...
pause > nul
exit /b
