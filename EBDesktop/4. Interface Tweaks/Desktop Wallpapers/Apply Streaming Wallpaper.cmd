@echo off
title Apply EB Streaming Wallpaper
set "wpPath=%windir%\EBModules\Wallpapers\eb-streaming.png"
if exist "%wpPath%" (
    reg add "HKCU\Control Panel\Desktop" /v Wallpaper /t REG_SZ /d "%wpPath%" /f > nul
    rundll32.exe user32.dll,UpdatePerUserSystemParameters
    echo ✓ Streaming wallpaper applied.
) else (
    echo ✗ Wallpaper file missing.
)
timeout /t 2 > nul
exit
