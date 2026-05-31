@echo off
title EB Context Menu Fix
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
echo %ESC%[36m  ║%ESC%[1m%ESC%[34m             📂 EB Classic Context Menu 📂              %ESC%[0m%ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╠═════════════════════════════════════════════════════════╣%ESC%[0m
echo %ESC%[36m  ║%ESC%[0m  Restores the Win10-style right-click menu.          %ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╚═════════════════════════════════════════════════════════╝%ESC%[0m
echo.

reg query "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" > nul 2>&1
if %errorlevel%==0 (
    echo   Current Status: %ESC%[32mCLASSIC MENU ACTIVE%ESC%[0m
    choice /m "  Revert to Windows 11 Modern Menu? "
    if errorlevel 2 exit /b
    reg delete "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" /f > nul
    echo   %ESC%[31m✓ Modern Menu Restored.%ESC%[0m
) else (
    echo   Current Status: %ESC%[31mMODERN MENU ACTIVE%ESC%[0m
    choice /m "  Enable Classic Context Menu? "
    if errorlevel 2 exit /b
    reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /ve /f > nul
    echo   %ESC%[32m✓ Classic Menu Enabled.%ESC%[0m
)

echo.
echo   Restarting Explorer to apply changes...
taskkill /f /im explorer.exe > nul
start explorer.exe
echo.
echo   Press any key to exit...
pause > nul
exit /b
