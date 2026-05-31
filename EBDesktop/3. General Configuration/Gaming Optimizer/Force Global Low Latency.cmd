@echo off
title EB Global Low Latency Force
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
echo %ESC%[36m  ║%ESC%[1m%ESC%[32m           ⚡ Force Global Low Latency ⚡             %ESC%[0m%ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╠═════════════════════════════════════════════════════════╣%ESC%[0m
echo %ESC%[36m  ║%ESC%[0m  Enabling driver-level latency reduction modes.      %ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╚═════════════════════════════════════════════════════════╝%ESC%[0m
echo.

echo   [1/3] Detecting GPU Vendor...

:: NVIDIA Check
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "ProviderName" 2>nul | find "NVIDIA" >nul
if %errorlevel%==0 (
    echo   %ESC%[32m[✓] NVIDIA Detected.%ESC%[0m
    echo   Setting 'Ultra Low Latency' to Ultra...
    :: This is a simplified registry hack for NVIDIA Global profile
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "UltraLowLatencyMode" /t REG_DWORD /d 2 /f > nul
    :: Also disable G-Sync/FreeSync if desired? No, let the user decide.
)

:: AMD Check
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "ProviderName" 2>nul | find "Advanced Micro Devices" >nul
if %errorlevel%==0 (
    echo   %ESC%[32m[✓] AMD Detected.%ESC%[0m
    echo   Setting 'Anti-Lag' to Enabled...
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "AntiLag" /t REG_DWORD /d 1 /f > nul
)

echo   [2/3] Optimizing DirectX Flip Model...
:: Done via tweak, but reinforced here
reg add "HKLM\SOFTWARE\Microsoft\DirectX\UserGpuPreferences" /v "DirectXFlipModel" /t REG_DWORD /d 1 /f > nul

echo   [3/3] Setting Global High Performance...
reg add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "GpuPreference" /t REG_DWORD /d 2 /f > nul

echo.
echo   %ESC%[1m%ESC%[32m  ✓ Global Low Latency Modes Enabled! %ESC%[0m
echo   Restarting your PC is recommended for changes to take effect.
echo.
echo   Press any key to exit...
pause > nul
exit /b
