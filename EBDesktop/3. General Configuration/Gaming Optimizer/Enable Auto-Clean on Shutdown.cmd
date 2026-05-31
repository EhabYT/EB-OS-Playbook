@echo off
title EB Auto-Clean Setup
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
echo %ESC%[36m  ║%ESC%[1m%ESC%[32m             🧹 EB Auto-Clean Setup 🧹              %ESC%[0m%ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╠═════════════════════════════════════════════════════════╣%ESC%[0m
echo %ESC%[36m  ║%ESC%[0m  Configures Windows to clean junk on shutdown.       %ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╚═════════════════════════════════════════════════════════╝%ESC%[0m
echo.

echo   [1/2] Creating Auto-Clean Script...
echo @echo off > %windir%\EBModules\Scripts\AutoClean.cmd
echo del /f /s /q %%temp%%\* >> %windir%\EBModules\Scripts\AutoClean.cmd
echo del /f /s /q %%systemroot%%\temp\* >> %windir%\EBModules\Scripts\AutoClean.cmd
echo ipconfig /flushdns >> %windir%\EBModules\Scripts\AutoClean.cmd

echo   [2/2] Registering Group Policy Shutdown Script...
:: Using a registry hack to register a shutdown script (GPEDIT equivalent)
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Shutdown\0" /v "GPO-ID" /t REG_SZ /d "LocalGPO" /f > nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Shutdown\0" /v "SOM-ID" /t REG_SZ /d "Local" /f > nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Shutdown\0\0" /v "Script" /t REG_SZ /d "%windir%\EBModules\Scripts\AutoClean.cmd" /f > nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Shutdown\0\0" /v "Parameters" /t REG_SZ /d "" /f > nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Shutdown\0\0" /v "IsPowershell" /t REG_DWORD /d 0 /f > nul

echo.
echo   %ESC%[1m%ESC%[32m  ✓ AUTO-CLEAN ENABLED! %ESC%[0m
echo   Your PC will now self-clean every time you shutdown.
echo.
echo   Press any key to exit...
pause > nul
exit /b
