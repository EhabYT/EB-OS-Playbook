@echo off
title EB Input Device Optimizer
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
echo %ESC%[36m  ║%ESC%[1m%ESC%[35m           🖱️ EB Input Device Optimizer 🖱️            %ESC%[0m%ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╠═════════════════════════════════════════════════════════╣%ESC%[0m
echo %ESC%[36m  ║%ESC%[0m  Disabling power-saving on HID input devices.        %ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╚═════════════════════════════════════════════════════════╝%ESC%[0m
echo.

echo   [1/2] Finding Mice and Keyboards...
powershell -c "Get-PnpDevice -Class Mouse,Keyboard -ErrorAction SilentlyContinue | ForEach-Object { $regPath = 'HKLM:\SYSTEM\CurrentControlSet\Enum\' + $_.InstanceId + '\Device Parameters'; if (Test-Path $regPath) { Set-ItemProperty -Path $regPath -Name 'SelectiveSuspendEnabled' -Value 0 -Force; Set-ItemProperty -Path $regPath -Name 'EnhancedPowerManagementEnabled' -Value 0 -Force; echo '      - Optimized: $($_.FriendlyName)' } }"

echo.
echo   [2/2] Increasing HID Report Rate Priority...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" /v "MouseDataQueueSize" /t REG_DWORD /d 100 /f > nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" /v "KeyboardDataQueueSize" /t REG_DWORD /d 100 /f > nul

echo.
echo   %ESC%[1m%ESC%[32m  ✓ Input devices optimized for zero-latency! %ESC%[0m
echo   Unplug and replug your mouse/keyboard or restart PC.
echo.
echo   Press any key to exit...
pause > nul
exit /b
