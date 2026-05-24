$ErrorActionPreference = 'SilentlyContinue'

Write-Host "Disabling Reserved Storage"
Set-WindowsReservedStorageState -State Disabled

Stop-Service -Name "bits" -Force | Out-Null
Stop-Service -Name "appidsvc" -Force | Out-Null
Stop-Service -Name "dps" -Force | Out-Null
Stop-Service -Name "wuauserv" -Force | Out-Null
# Stop-Service -Name "cryptsvc" -Force | Out-Null # Intermittent issues stopping this service

Write-Host "Cleaning up leftovers"
$foldersToRemove = @(
    "CbsTemp",
    "Logs",
    "SoftwareDistribution",
    "System32\LogFiles",
    "System32\LogFiles\WMI,"
    "System32\SleepStudy",
    "System32\sru",
    "System32\WDI\LogFiles",
    "System32\winevt\Logs",
    "SystemTemp",
    "Temp"

    # "WinSxS\Backup"
    # "Panther",
    # "Prefetch"
)

foreach ($folderName in $foldersToRemove) {
    $folderPath = Join-Path $env:SystemRoot $folderName
    if (Test-Path $folderPath) {
        Remove-Item -Path "$folderPath\*" -Force -Recurse | Out-Null
    }
}

# Remove-Item -Path "C:\Program Files\WindowsApps\MicrosoftWindows.Client.WebExperience*" -Recurse -Force

# Get-ChildItem -Path "$env:SystemRoot" -Filter *.log -File -Recurse -Force | Remove-Item -Recurse -Force | Out-Null

Write-Host "Cleaning up %TEMP%"
Get-ChildItem -Path "$env:TEMP" -Exclude "AME", "Revision-Tool" | Remove-Item -Recurse -Force

# Just in case
Start-ScheduledTask -TaskPath "\Microsoft\Windows\DiskCleanup\" -TaskName "SilentCleanup"

# Write-Host "Cleaning up Retail Demo Content"
# Start-ScheduledTask -TaskPath "\Microsoft\Windows\RetailDemo\" -TaskName "CleanupOfflineContent"

# Write-Host "Cleaning up the WinSxS Components"
# DISM /Online /Cleanup-Image /StartComponentCleanup

$edgeUpdatePath = ${env:ProgramFiles(x86)} + "\Microsoft\EdgeUpdate\Download"
if (Test-Path -Path $edgeUpdatePath) {
    Remove-Item -Path $edgeUpdatePath -Force -Recurse | Out-Null
}