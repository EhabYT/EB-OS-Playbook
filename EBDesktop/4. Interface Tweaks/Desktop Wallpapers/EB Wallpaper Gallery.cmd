@echo off
title EB Wallpaper Gallery
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
cls
echo.
echo %ESC%[36m  ╔═════════════════════════════════════════════════════════╗%ESC%[0m
echo %ESC%[36m  ║%ESC%[1m%ESC%[33m               🖼️  EB Wallpaper Gallery 🖼️               %ESC%[0m%ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╠═════════════════════════════════════════════════════════╣%ESC%[0m
echo %ESC%[36m  ║%ESC%[0m  Choose a premium wallpaper for your setup.          %ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╚═════════════════════════════════════════════════════════╝%ESC%[0m
echo.
echo   [1] %ESC%[31mUltimate Gaming v2.0%ESC%[0m (Carbon ^& Neon)
echo   [2] %ESC%[35mUltimate Streaming v2.0%ESC%[0m (Studio ^& Bokeh)
echo   [3] %ESC%[34mEB Ultimate Default%ESC%[0m (Glassmorphism)
echo   [4] %ESC%[32mRetro Synthwave%ESC%[0m (80s Neon)
echo   [5] %ESC%[36mLegacy Dark v1.3%ESC%[0m
echo   [6] %ESC%[37mLegacy Light v1.3%ESC%[0m
echo.
echo   [0] Exit
echo.

set /p choice="  Selection > "

if "%choice%"=="1" set "wp=eb-gaming.png"
if "%choice%"=="2" set "wp=eb-streaming.png"
if "%choice%"=="3" set "wp=eb-solid.png"
if "%choice%"=="4" set "wp=eb-retro.png"
if "%choice%"=="5" set "wp=eb-v1.3.x-dark.png"
if "%choice%"=="6" set "wp=eb-v1.3.x-light.png"
if "%choice%"=="0" exit /b

if defined wp (
    set "wpPath=%windir%\ebModules\Wallpapers\%wp%"
    if exist "%wpPath%" (
        reg add "HKCU\Control Panel\Desktop" /v Wallpaper /t REG_SZ /d "%wpPath%" /f > nul
        rundll32.exe user32.dll,UpdatePerUserSystemParameters
        echo.
        echo   %ESC%[32m✓ Wallpaper Applied!%ESC%[0m
        timeout /t 2 > nul
    ) else (
        echo.
        echo   %ESC%[31m✗ Wallpaper file not found in C:\Windows\ebModules\...%ESC%[0m
        pause
    )
)
goto menu
