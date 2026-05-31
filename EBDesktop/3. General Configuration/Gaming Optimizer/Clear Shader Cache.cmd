@echo off
title EB Shader Cache Cleaner
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
echo %ESC%[36m  ║%ESC%[1m%ESC%[33m             🧹 EB Shader Cache Cleaner 🧹             %ESC%[0m%ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╠═════════════════════════════════════════════════════════╣%ESC%[0m
echo %ESC%[36m  ║%ESC%[0m  Clears DX/NVIDIA/AMD caches to fix stutters.        %ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╚═════════════════════════════════════════════════════════╝%ESC%[0m
echo.

echo   [1/4] Clearing DirectX Shader Cache...
del /f /s /q %LocalAppData%\Microsoft\DirectX\ShaderCache\* > nul 2>&1

echo   [2/4] Clearing NVIDIA Shader Cache...
del /f /s /q %LocalAppData%\NVIDIA\DXCache\* > nul 2>&1
del /f /s /q %LocalAppData%\NVIDIA\GLCache\* > nul 2>&1
del /f /s /q %AppData%\NVIDIA\ComputeCache\* > nul 2>&1

echo   [3/4] Clearing AMD Shader Cache...
del /f /s /q %LocalAppData%\AMD\DxCache\* > nul 2>&1

echo   [4/4] Clearing Steam Shader Cache...
:: Try to find Steam path
for /f "tokens=2*" %%a in ('reg query "HKCU\Software\Valve\Steam" /v "SteamPath" 2^>nul') do set "SteamPath=%%b"
if defined SteamPath (
    del /f /s /q "%SteamPath%\steamapps\shadercache\*" > nul 2>&1
)

echo.
echo   %ESC%[1m%ESC%[32m  ✓ SHADER CACHES CLEARED! %ESC%[0m
echo   Next game launch might be slow while rebuilding.
echo.
echo   Press any key to exit...
pause > nul
exit /b
