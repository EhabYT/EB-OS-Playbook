@echo off
title EB Streamer Privacy Mode
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

mode con: cols=65 lines=25
cls

echo.
echo %ESC%[36m  ╔═════════════════════════════════════════════════════════╗%ESC%[0m
echo %ESC%[36m  ║%ESC%[1m%ESC%[35m           🔒 EB Streamer Privacy Mode 🔒            %ESC%[0m%ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╠═════════════════════════════════════════════════════════╣%ESC%[0m
echo %ESC%[36m  ║%ESC%[0m  Hardens Windows privacy for live broadcasting.      %ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╚═════════════════════════════════════════════════════════╝%ESC%[0m
echo.

echo   [1/5] Enabling Focus Assist (Do Not Disturb)...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" /v "NOC_GLOBAL_SETTING_TOASTS_ENABLED" /t REG_DWORD /d 0 /f > nul

echo   [2/5] Hiding Personal Email on Lock Screen...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "DontDisplayLockedUserId" /t REG_DWORD /d 3 /f > nul

echo   [3/5] Disabling Recent Files in Quick Access...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "ShowRecent" /t REG_DWORD /d 0 /f > nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "ShowFrequent" /t REG_DWORD /d 0 /f > nul

echo   [4/5] Disabling "Suggestions" in Start Menu...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SystemPaneSuggestionsEnabled" /t REG_DWORD /d 0 /f > nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338388Enabled" /t REG_DWORD /d 0 /f > nul

echo   [5/5] Clearing Jump Lists (Recent App Files)...
del /f /q %APPDATA%\Microsoft\Windows\Recent\AutomaticDestinations\* > nul 2>&1
del /f /q %APPDATA%\Microsoft\Windows\Recent\CustomDestinations\* > nul 2>&1

echo.
echo   %ESC%[1m%ESC%[32m  ✓ STREAMER PRIVACY MODE ENGAGED! %ESC%[0m
echo   Your personal info is now shielded from view.
echo.
echo   Press any key to exit...
pause > nul
exit /b
