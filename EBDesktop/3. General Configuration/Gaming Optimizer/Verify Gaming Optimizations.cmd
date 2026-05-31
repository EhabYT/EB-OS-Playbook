@echo off
title EB Gaming Optimizer - Latency Check
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

mode con: cols=70 lines=40
cls

echo.
echo %ESC%[36m  ╔══════════════════════════════════════════════════════════════╗%ESC%[0m
echo %ESC%[36m  ║%ESC%[1m%ESC%[33m            🎮 EB Gaming Optimizer v1.5.0 🎮            %ESC%[0m%ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╠══════════════════════════════════════════════════════════════╣%ESC%[0m
echo %ESC%[36m  ║%ESC%[0m  Verifying gaming optimizations are active...            %ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╚══════════════════════════════════════════════════════════════╝%ESC%[0m
echo.

set "PASS=0"
set "FAIL=0"

:: Check Timer Resolution
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "GlobalTimerResolutionRequests" 2>nul | find "0x1" >nul
if %errorlevel%==0 (
    echo   %ESC%[32m[✓]%ESC%[0m Global Timer Resolution          — ENABLED
    set /a PASS+=1
) else (
    echo   %ESC%[31m[✗]%ESC%[0m Global Timer Resolution          — DISABLED
    set /a FAIL+=1
)

:: Check HAGS
reg query "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" 2>nul | find "0x2" >nul
if %errorlevel%==0 (
    echo   %ESC%[32m[✓]%ESC%[0m Hardware GPU Scheduling (HAGS)   — ENABLED
    set /a PASS+=1
) else (
    echo   %ESC%[31m[✗]%ESC%[0m Hardware GPU Scheduling (HAGS)   — DISABLED
    set /a FAIL+=1
)

:: Check Game DVR Disabled
reg query "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" 2>nul | find "0x0" >nul
if %errorlevel%==0 (
    echo   %ESC%[32m[✓]%ESC%[0m Game DVR                        — DISABLED
    set /a PASS+=1
) else (
    echo   %ESC%[31m[✗]%ESC%[0m Game DVR                        — STILL ACTIVE
    set /a FAIL+=1
)

:: Check Power Throttling
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" 2>nul | find "0x1" >nul
if %errorlevel%==0 (
    echo   %ESC%[32m[✓]%ESC%[0m Power Throttling                 — DISABLED
    set /a PASS+=1
) else (
    echo   %ESC%[31m[✗]%ESC%[0m Power Throttling                 — ACTIVE
    set /a FAIL+=1
)

:: Check FSO
reg query "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehaviorMode" 2>nul | find "0x2" >nul
if %errorlevel%==0 (
    echo   %ESC%[32m[✓]%ESC%[0m Fullscreen Optimizations         — DISABLED
    set /a PASS+=1
) else (
    echo   %ESC%[31m[✗]%ESC%[0m Fullscreen Optimizations         — ACTIVE
    set /a FAIL+=1
)

:: Check Mouse Acceleration
reg query "HKCU\Control Panel\Mouse" /v "MouseSpeed" 2>nul | find "0" >nul
if %errorlevel%==0 (
    echo   %ESC%[32m[✓]%ESC%[0m Mouse Acceleration               — DISABLED
    set /a PASS+=1
) else (
    echo   %ESC%[31m[✗]%ESC%[0m Mouse Acceleration               — ACTIVE
    set /a FAIL+=1
)

:: Check GPU Preemption
reg query "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" /v "EnablePreemption" 2>nul | find "0x0" >nul
if %errorlevel%==0 (
    echo   %ESC%[32m[✓]%ESC%[0m GPU Preemption                   — DISABLED
    set /a PASS+=1
) else (
    echo   %ESC%[31m[✗]%ESC%[0m GPU Preemption                   — ACTIVE
    set /a FAIL+=1
)

:: Check Network Throttling
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" 2>nul | find "0xffffffff" >nul
if %errorlevel%==0 (
    echo   %ESC%[32m[✓]%ESC%[0m Network Throttling               — DISABLED
    set /a PASS+=1
) else (
    echo   %ESC%[31m[✗]%ESC%[0m Network Throttling               — ACTIVE
    set /a FAIL+=1
)

:: Check SysMain
sc query SysMain >nul 2>&1
if %errorlevel% neq 0 (
    echo   %ESC%[32m[✓]%ESC%[0m SysMain/Superfetch               — NOT FOUND
    set /a PASS+=1
) else (
    sc query SysMain 2>nul | find "STOPPED" >nul
    if %errorlevel%==0 (
        echo   %ESC%[32m[✓]%ESC%[0m SysMain/Superfetch               — STOPPED
        set /a PASS+=1
    ) else (
        echo   %ESC%[31m[✗]%ESC%[0m SysMain/Superfetch               — RUNNING
        set /a FAIL+=1
    )
)

:: Check Dynamic Tick
bcdedit /enum {current} 2>nul | find "disabledynamictick" | find "Yes" >nul
if %errorlevel%==0 (
    echo   %ESC%[32m[✓]%ESC%[0m Dynamic Tick                     — DISABLED
    set /a PASS+=1
) else (
    echo   %ESC%[31m[✗]%ESC%[0m Dynamic Tick                     — ACTIVE
    set /a FAIL+=1
)

:: Check Ultimate Performance Plan
powercfg /getactivescheme 2>nul | find "e9a42b02-d5df-448d-aa00-03f14749eb61" >nul
if %errorlevel%==0 (
    echo   %ESC%[32m[✓]%ESC%[0m Ultimate Performance Plan        — ACTIVE
    set /a PASS+=1
) else (
    echo   %ESC%[33m[~]%ESC%[0m Ultimate Performance Plan        — NOT ACTIVE
    set /a FAIL+=1
)

echo.
echo   ─────────────────────────────────────────────────────────
set /a TOTAL=PASS+FAIL
echo.
if %FAIL%==0 (
    echo   %ESC%[1m%ESC%[32m  🏆 PERFECT: All %TOTAL% gaming optimizations verified! %ESC%[0m
) else (
    echo   %ESC%[1m%ESC%[33m  ⚠ %PASS%/%TOTAL% optimizations active, %FAIL% need attention %ESC%[0m
)
echo.

echo   ─────────────────────────────────────────────────────────
echo.
echo   %ESC%[36mTimer Resolution Test:%ESC%[0m
echo   Running MeasureSleep to verify timer resolution...
echo.

if exist "%windir%\EBDesktop\3. General Configuration\Timer Resolution\! MeasureSleep.exe" (
    "%windir%\EBDesktop\3. General Configuration\Timer Resolution\! MeasureSleep.exe"
) else (
    echo   MeasureSleep.exe not found. Skipping timer test.
)

echo.
echo   %ESC%[36mPress any key to exit...%ESC%[0m
pause > nul
exit /b
