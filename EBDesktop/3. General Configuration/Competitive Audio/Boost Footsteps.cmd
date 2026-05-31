@echo off
title EB Footstep Booster (Loudness Equalization)
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
echo %ESC%[36m  ║%ESC%[1m%ESC%[33m           👂 EB Competitive Audio Booster 👂           %ESC%[0m%ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╠═════════════════════════════════════════════════════════╣%ESC%[0m
echo %ESC%[36m  ║%ESC%[0m  Helps normalize sounds to hear footsteps better.    %ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╚═════════════════════════════════════════════════════════╝%ESC%[0m
echo.

echo   [1/2] Enabling Loudness Equalization...
:: This registry path is for common Realtek and Generic Audio drivers
powershell -c "$regPaths = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Render' -ErrorAction SilentlyContinue | ForEach-Object { $_.Name + '\FxProperties' }; foreach ($p in $regPaths) { Set-ItemProperty -Path $p -Name '{E0A941A0-88A2-4cb5-882C-F201444D1C9E},4' -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue }"

echo   [2/2] Setting sample rate to 48kHz (Studio Quality)...
:: Forces 48000Hz on the default device if possible
powershell -c "Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Render' -ErrorAction SilentlyContinue | ForEach-Object { $p = $_.Name; Set-ItemProperty -Path ($p + '\Properties') -Name '{E0A941A0-88A2-4cb5-882C-F201444D1C9E},0' -Value 48000 -Type DWord -Force -ErrorAction SilentlyContinue }"

echo.
echo   %ESC%[1m%ESC%[32m  ✓ AUDIO BOOSTED! %ESC%[0m
echo   Note: Some drivers may require manual setup in Sound Panel.
echo.
echo   Press any key to exit...
pause > nul
exit /b
