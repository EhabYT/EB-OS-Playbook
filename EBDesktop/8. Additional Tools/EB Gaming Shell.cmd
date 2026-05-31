@echo off
title EB Gaming Shell
chcp 65001 > nul
for /f %%a in ('forfiles /m "%~nx0" /c "cmd /c echo 0x1B"') do set "ESC=%%a"

echo.
echo %ESC%[36m  ╔═════════════════════════════════════════════════════════╗%ESC%[0m
echo %ESC%[36m  ║%ESC%[1m%ESC%[33m               🎮 EB GAMING SHELL 🎮                 %ESC%[0m%ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╠═════════════════════════════════════════════════════════╣%ESC%[0m
echo %ESC%[36m  ║%ESC%[0m  Launching performance-tuned PowerShell...           %ESC%[36m║%ESC%[0m
echo %ESC%[36m  ╚═════════════════════════════════════════════════════════╝%ESC%[0m
echo.

powershell.exe -NoExit -Command "& {
    Write-Host '   _________________________________________________' -ForegroundColor Cyan
    Write-Host '  |                                                 |' -ForegroundColor Cyan
    Write-Host '  |    EB PLAYBOOK — ULTIMATE GAMING EDITION v1.5   |' -ForegroundColor Yellow
    Write-Host '  |_________________________________________________|' -ForegroundColor Cyan
    Write-Host ''
    Write-Host '   Available Gaming Aliases:' -ForegroundColor DarkGray
    Write-Host '   - flush      : Flush DNS and ARP cache'
    Write-Host '   - tournament : Enter Tournament Mode'
    Write-Host '   - sync       : Fix Audio Desync'
    Write-Host '   - clear      : Clear Shader Caches'
    Write-Host ''

    function flush { ipconfig /flushdns; arp -d * }
    function tournament { Start-Process 'C:\Windows\EBDesktop\3. General Configuration\Gaming Optimizer\Tournament Mode.cmd' -Verb RunAs }
    function sync { Start-Process 'C:\Windows\EBDesktop\3. General Configuration\Streaming Optimizer\Fix Audio Desync.cmd' -Verb RunAs }
    function clear { Start-Process 'C:\Windows\EBDesktop\3. General Configuration\Gaming Optimizer\Clear Shader Cache.cmd' -Verb RunAs }

    Set-Alias -Name f -Value flush
    Set-Alias -Name t -Value tournament
    Set-Alias -Name s -Value sync
    Set-Alias -Name c -Value clear
}"
