@echo off
title EB Ultimate Power Plan Importer
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
echo %ESC%[36m  ║%ESC%[1m%ESC%[33m           ⚡ EB Ultimate Power Importer ⚡             %ESC%[0m%ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╠═════════════════════════════════════════════════════════╣%ESC%[0m
echo %ESC%[36m  ║%ESC%[0m  Unlocking the hidden Ultimate Power Plan.           %ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╚═════════════════════════════════════════════════════════╝%ESC%[0m
echo.

echo   [1/2] Unlocking Ultimate Performance...
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 > nul

echo   [2/2] Setting as Active Plan...
powercfg /setactive e9a42b02-d5df-448d-aa00-03f14749eb61 > nul

echo.
echo   %ESC%[1m%ESC%[32m  ✓ ULTIMATE PERFORMANCE ACTIVE! %ESC%[0m
echo.
echo   Press any key to exit...
pause > nul
exit /b
