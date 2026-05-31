@echo off
title EB Tournament Mode
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
echo %ESC%[36m  ║%ESC%[1m%ESC%[31m           🔥 ENTER TOURNAMENT MODE 🔥              %ESC%[0m%ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╠═════════════════════════════════════════════════════════╣%ESC%[0m
echo %ESC%[36m  ║%ESC%[0m  Preparing your system for peak competition.         %ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╚═════════════════════════════════════════════════════════╝%ESC%[0m
echo.

echo   [1/7] Forcing Ultimate Performance Power Plan...
powercfg /setactive e9a42b02-d5df-448d-aa00-03f14749eb61 > nul 2>&1

echo   [2/7] Emptying Working Set (RAM Cleanup)...
powershell -c "$sig = '[DllImport(\"psapi.dll\")] public static extern int EmptyWorkingSet(IntPtr hwProc);'; $t = Add-Type -MemberDefinition $sig -Name 'Mem' -Namespace 'Win32' -PassThru; Get-Process | ForEach-Object { try { $t::EmptyWorkingSet($_.Handle) | Out-Null } catch {} }" > nul 2>&1

echo   [3/7] Flushing DNS and ARP Cache...
ipconfig /flushdns > nul
arp -d * > nul 2>&1

echo   [4/7] Suspending Non-Essential background services...
sc stop SysMain > nul 2>&1
sc stop WSearch > nul 2>&1

echo   [5/7] Silencing all Windows Notifications...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" /v "NOC_GLOBAL_SETTING_TOASTS_ENABLED" /t REG_DWORD /d 0 /f > nul

echo   [6/7] Terminating non-critical background apps...
powershell -c "Get-Process | Where-Object { $_.Name -match 'OneDrive|Teams|Cortana|PhoneExperienceHost' } | Stop-Process -Force -ErrorAction SilentlyContinue" > nul 2>&1

echo   [7/7] Boosting Explorer responsiveness...
taskkill /f /im explorer.exe > nul
start explorer.exe

echo.
echo   %ESC%[1m%ESC%[32m  🏆 TOURNAMENT MODE ACTIVE! %ESC%[0m
echo   System is now at maximum readiness.
echo.
echo   Press any key to return to normal desktop...
pause > nul
exit /b
