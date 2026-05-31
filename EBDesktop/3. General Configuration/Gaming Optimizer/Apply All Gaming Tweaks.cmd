@echo off
title EB Gaming Optimizer - Apply All Gaming Tweaks
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
mode con: cols=65 lines=30
cls

echo.
echo %ESC%[36m  ╔═════════════════════════════════════════════════════════╗%ESC%[0m
echo %ESC%[36m  ║%ESC%[1m%ESC%[33m          🎮 Apply All Gaming Tweaks 🎮              %ESC%[0m%ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╠═════════════════════════════════════════════════════════╣%ESC%[0m
echo %ESC%[36m  ║%ESC%[0m  This applies all gaming optimizations manually.     %ESC%[36m║%ESC%[0m
echo %ESC%[36m  ║%ESC%[0m  Use this if you didn't select Gaming during setup.  %ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╚═════════════════════════════════════════════════════════╝%ESC%[0m
echo.

if not "%~1"=="/silent" (
    echo   %ESC%[33mWARNING: These are aggressive performance tweaks.%ESC%[0m
    echo   %ESC%[33mThey are designed for dedicated gaming PCs.%ESC%[0m
    echo.
    choice /c YN /m "  Continue"
    if errorlevel 2 exit /b
    echo.
)

echo   [1/10] Enabling HAGS...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d 2 /f > nul

echo   [2/10] Disabling Fullscreen Optimizations...
reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehaviorMode" /t REG_DWORD /d 2 /f > nul
reg add "HKCU\System\GameConfigStore" /v "GameDVR_HonorUserFSEBehaviorMode" /t REG_DWORD /d 1 /f > nul

echo   [3/10] Disabling Game DVR...
reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d 0 /f > nul
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d 0 /f > nul

echo   [4/10] Disabling Power Throttling...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d 1 /f > nul

echo   [5/10] Disabling GPU Preemption...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" /v "EnablePreemption" /t REG_DWORD /d 0 /f > nul

echo   [6/10] Forcing Timer Resolution...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "GlobalTimerResolutionRequests" /t REG_DWORD /d 1 /f > nul

echo   [7/10] Disabling Network Throttling...
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 0xFFFFFFFF /f > nul
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 0 /f > nul

echo   [8/10] Configuring MMCSS Games profile...
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f > nul
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d 6 /f > nul
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d "High" /f > nul
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d "High" /f > nul

echo   [9/10] Disabling Dynamic Tick...
bcdedit /set disabledynamictick yes > nul 2>&1
bcdedit /set useplatformclock false > nul 2>&1
bcdedit /set tscsyncpolicy enhanced > nul 2>&1

echo   [10/10] Disabling SysMain ^& WSearch...
sc query SysMain > nul 2>&1 && (
    sc config SysMain start=disabled > nul 2>&1
    sc stop SysMain > nul 2>&1
)
sc config WSearch start=disabled > nul 2>&1
sc stop WSearch > nul 2>&1

echo.
echo   %ESC%[1m%ESC%[32m  ✓ All gaming optimizations applied successfully! %ESC%[0m
echo.
echo   %ESC%[33mA reboot is required for all changes to take effect.%ESC%[0m
echo.
if not "%~1"=="/silent" (
    choice /c YN /m "  Reboot now"
    if errorlevel 2 goto :skipReboot
    shutdown /r /t 3 /c "EB Gaming Optimizer - Rebooting for changes..."
    exit /b
)
:skipReboot
echo   Press any key to exit...
pause > nul
exit /b
