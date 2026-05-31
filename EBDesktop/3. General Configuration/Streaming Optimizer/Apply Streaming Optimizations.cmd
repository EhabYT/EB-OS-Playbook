@echo off
title EB Streaming Optimizer - Apply Optimizations
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
echo %ESC%[36m  ║%ESC%[1m%ESC%[35m        📡 Apply Streaming Optimizations 📡          %ESC%[0m%ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╠═════════════════════════════════════════════════════════╣%ESC%[0m
echo %ESC%[36m  ║%ESC%[0m  Configures Windows for zero-frame-drop streaming.   %ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╚═════════════════════════════════════════════════════════╝%ESC%[0m
echo.

echo   [1/5] Setting Encoder Priority (MMCSS Capture)...
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Capture" /v "GPU Priority" /t REG_DWORD /d 8 /f > nul
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Capture" /v "Priority" /t REG_DWORD /d 2 /f > nul
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Capture" /v "Scheduling Category" /t REG_SZ /d "High" /f > nul
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 10 /f > nul

echo   [2/5] Hardening Audio Pipeline...
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio" /v "Priority" /t REG_DWORD /d 6 /f > nul
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio" /v "Scheduling Category" /t REG_SZ /d "High" /f > nul

echo   [3/5] Tuning Network Upload (TCP Windows)...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "DefaultSendWindow" /t REG_DWORD /d 65536 /f > nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "DefaultReceiveWindow" /t REG_DWORD /d 65536 /f > nul

echo   [4/5] Optimizing USB Capture Devices...
powershell -c "Get-PnpDevice -Class Camera,Image,USB -ErrorAction SilentlyContinue | Where-Object { $_.FriendlyName -match 'Capture|Webcam|Camera|Video' } | ForEach-Object { $regPath = 'HKLM:\SYSTEM\CurrentControlSet\Enum\' + $_.InstanceId + '\Device Parameters'; if (Test-Path $regPath) { Set-ItemProperty -Path $regPath -Name 'SelectiveSuspendEnabled' -Value 0 -Force; Set-ItemProperty -Path $regPath -Name 'EnhancedPowerManagementEnabled' -Value 0 -Force } }" > nul 2>&1

echo   [5/5] Creating Auto-Priority Task...
powershell -c "$p = '$env:windir\EBModules\Scripts\ElevateStreamingApps.ps1'; if (!(Test-Path $p)) { New-Item -Path $p -Force; Set-Content -Path $p -Value 'Get-Process -Name obs64,obs32,streamlabs | ForEach-Object { $_.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::High }' }; $a = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-NoProfile -WindowStyle Hidden -File ' + $p; $t = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 1); Register-ScheduledTask -TaskName 'EB Streaming Priority' -Action $a -Trigger $t -Principal (New-ScheduledTaskPrincipal -UserId 'SYSTEM' -RunLevel Highest) -Force" > nul 2>&1

echo.
echo   %ESC%[1m%ESC%[32m  ✓ Streaming optimizations applied successfully! %ESC%[0m
echo.
echo   Press any key to exit...
pause > nul
exit /b
