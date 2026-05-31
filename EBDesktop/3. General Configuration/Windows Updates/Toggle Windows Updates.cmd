@echo off
setlocal EnableDelayedExpansion
title EB Windows Update Manager
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

:menu
for /f "tokens=3" %%a in ('sc qc wuauserv ^| findstr /i START_TYPE') do set "WUState=%%a"
set "statusText=%ESC%[32mENABLED%ESC%[0m"
if /i "!WUState!"=="DISABLED" set "statusText=%ESC%[31mDISABLED%ESC%[0m"

cls
echo.
echo %ESC%[36m  ╔═════════════════════════════════════════════════════════╗%ESC%[0m
echo %ESC%[36m  ║%ESC%[1m%ESC%[34m            🌐 EB Windows Update Manager 🌐             %ESC%[0m%ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╠═════════════════════════════════════════════════════════╣%ESC%[0m
echo %ESC%[36m  ║%ESC%[0m  Current Status: !statusText!                         %ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╚═════════════════════════════════════════════════════════╝%ESC%[0m
echo.
echo   [1] %ESC%[31mDisable Automatic Updates%ESC%[0m (Recommended for Gaming)
echo   [2] %ESC%[32mEnable Automatic Updates%ESC%[0m
echo.
echo   [0] Exit
echo.

set /p choice="  Selection > "

if "%choice%"=="1" goto disable
if "%choice%"=="2" goto enable
if "%choice%"=="0" exit
goto menu

:disable
echo.
echo   [1/2] Stopping Windows Update Service...
sc stop wuauserv >nul 2>&1
sc config wuauserv start= disabled >nul 2>&1
echo   [2/2] Disabling Update Tasks...
schtasks /Change /TN "Microsoft\Windows\WindowsUpdate\sih" /Disable >nul 2>&1
schtasks /Change /TN "Microsoft\Windows\WindowsUpdate\sihboot" /Disable >nul 2>&1
echo.
echo   %ESC%[1m%ESC%[31m  ✓ WINDOWS UPDATES DISABLED! %ESC%[0m
timeout /t 2 > nul
goto menu

:enable
echo.
echo   [1/2] Enabling Windows Update Service...
sc config wuauserv start= demand >nul 2>&1
sc start wuauserv >nul 2>&1
echo   [2/2] Enabling Update Tasks...
schtasks /Change /TN "Microsoft\Windows\WindowsUpdate\sih" /Enable >nul 2>&1
schtasks /Change /TN "Microsoft\Windows\WindowsUpdate\sihboot" /Enable >nul 2>&1
echo.
echo   %ESC%[1m%ESC%[32m  ✓ WINDOWS UPDATES ENABLED! %ESC%[0m
timeout /t 2 > nul
goto menu
