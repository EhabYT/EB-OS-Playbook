@echo off
title Apply EB Gaming Wallpaper
set "wpPath=%windir%\EBModules\Wallpapers\eb-gaming.png"
if exist "%wpPath%" (
    reg add "HKCU\Control Panel\Desktop" /v Wallpaper /t REG_SZ /d "%wpPath%" /f > nul
    rundll32.exe user32.dll,UpdatePerUserSystemParameters
    echo ✓ Gaming wallpaper applied.
) else (
    echo ✗ Wallpaper file missing.
)
timeout /t 2 > nul
exit
