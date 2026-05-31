@echo off
title EB Streaming Optimizer - Verification
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

mode con: cols=70 lines=30
cls

echo.
echo %ESC%[36m  ╔══════════════════════════════════════════════════════════════╗%ESC%[0m
echo %ESC%[36m  ║%ESC%[1m%ESC%[35m           📡 EB Streaming Optimizer v1.5.0 📡           %ESC%[0m%ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╠══════════════════════════════════════════════════════════════╣%ESC%[0m
echo %ESC%[36m  ║%ESC%[0m  Verifying streaming optimizations are active...          %ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╚══════════════════════════════════════════════════════════════╝%ESC%[0m
echo.

set "PASS=0"
set "FAIL=0"

:: Check Encoder Priority (MMCSS Capture)
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Capture" /v "GPU Priority" 2>nul | find "0x8" >nul
if %errorlevel%==0 (
    echo   %ESC%[32m[✓]%ESC%[0m GPU Encoder Priority (Capture)    — ENABLED
    set /a PASS+=1
) else (
    echo   %ESC%[31m[✗]%ESC%[0m GPU Encoder Priority (Capture)    — DISABLED
    set /a FAIL+=1
)

:: Check System Responsiveness (Reserved for background)
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" 2>nul | find "0xa" >nul
if %errorlevel%==0 (
    echo   %ESC%[32m[✓]%ESC%[0m Background Headroom (10%%)        — CONFIGURED
    set /a PASS+=1
) else (
    echo   %ESC%[33m[~]%ESC%[0m Background Headroom (Reserved)    — NOT OPTIMIZED (Default: 20%% or 0%%)
    set /a FAIL+=1
)

:: Check Audio MMCSS
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio" /v "Scheduling Category" 2>nul | find "High" >nul
if %errorlevel%==0 (
    echo   %ESC%[32m[✓]%ESC%[0m Audio Pipeline Hardening          — ENABLED
    set /a PASS+=1
) else (
    echo   %ESC%[31m[✗]%ESC%[0m Audio Pipeline Hardening          — DISABLED
    set /a FAIL+=1
)

:: Check Network Send Window
reg query "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "DefaultSendWindow" 2>nul | find "0x10000" >nul
if %errorlevel%==0 (
    echo   %ESC%[32m[✓]%ESC%[0m Network Upload Optimization       — ENABLED
    set /a PASS+=1
) else (
    echo   %ESC%[31m[✗]%ESC%[0m Network Upload Optimization       — DISABLED
    set /a FAIL+=1
)

:: Check Auto-Priority Task
schtasks /query /tn "EB Streaming Priority" >nul 2>&1
if %errorlevel%==0 (
    echo   %ESC%[32m[✓]%ESC%[0m Auto-Priority (OBS/Streamlabs)   — ACTIVE
    set /a PASS+=1
) else (
    echo   %ESC%[31m[✗]%ESC%[0m Auto-Priority (OBS/Streamlabs)   — MISSING
    set /a FAIL+=1
)

echo.
echo   ─────────────────────────────────────────────────────────
set /a TOTAL=PASS+FAIL
echo.
if %FAIL%==0 (
    echo   %ESC%[1m%ESC%[32m  🏆 PERFECT: All %TOTAL% streaming optimizations verified! %ESC%[0m
) else (
    echo   %ESC%[1m%ESC%[35m  📡 %PASS%/%TOTAL% optimizations active, %FAIL% need attention %ESC%[0m
)
echo.
echo   ─────────────────────────────────────────────────────────
echo.
echo   Press any key to exit...
pause > nul
exit /b
