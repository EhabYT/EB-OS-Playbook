@echo off
title EB Gaming Optimizer - Revert Gaming Tweaks
chcp 65001 > nul

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

for /f %%a in ('forfiles /m "%~nx0" /c "cmd /c echo 0x1B"') do set "ESC=%%a"
mode con: cols=65 lines=25
cls

echo.
echo %ESC%[36m  ╔═════════════════════════════════════════════════════════╗%ESC%[0m
echo %ESC%[36m  ║%ESC%[1m%ESC%[31m        ↩ Revert All Gaming Tweaks to Default ↩       %ESC%[0m%ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╚═════════════════════════════════════════════════════════╝%ESC%[0m
echo.

if not "%~1"=="/silent" (
    echo   This will restore Windows defaults for all gaming tweaks.
    echo.
    choice /c YN /m "  Continue"
    if errorlevel 2 exit /b
    echo.
)

echo   [1/8] Restoring HAGS default...
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /f > nul 2>&1

echo   [2/8] Restoring Fullscreen Optimizations...
reg delete "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehaviorMode" /f > nul 2>&1
reg delete "HKCU\System\GameConfigStore" /v "GameDVR_HonorUserFSEBehaviorMode" /f > nul 2>&1

echo   [3/8] Restoring Power Throttling...
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /f > nul 2>&1

echo   [4/8] Restoring GPU Preemption...
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" /v "EnablePreemption" /f > nul 2>&1

echo   [5/8] Restoring Timer Resolution...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "GlobalTimerResolutionRequests" /t REG_DWORD /d 0 /f > nul

echo   [6/8] Restoring Network Throttling defaults...
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 10 /f > nul
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 20 /f > nul

echo   [7/8] Restoring Dynamic Tick...
bcdedit /deletevalue disabledynamictick > nul 2>&1
bcdedit /deletevalue tscsyncpolicy > nul 2>&1

echo   [8/8] Restoring SysMain ^& WSearch...
sc query SysMain > nul 2>&1 && (
    sc config SysMain start=auto > nul 2>&1
    sc start SysMain > nul 2>&1
)
sc config WSearch start=delayed-auto > nul 2>&1
sc start WSearch > nul 2>&1

echo.
echo   %ESC%[1m%ESC%[32m  ✓ All gaming tweaks reverted to Windows defaults. %ESC%[0m
echo.
echo   %ESC%[33mA reboot is required for all changes to take effect.%ESC%[0m
echo.
if not "%~1"=="/silent" (
    choice /c YN /m "  Reboot now"
    if errorlevel 2 goto :skipReboot
    shutdown /r /t 3 /c "EB Gaming Optimizer - Rebooting for revert..."
    exit /b
)
:skipReboot
echo   Press any key to exit...
pause > nul
exit /b
