param(
    [Parameter(Mandatory=$false)]
    [string]$SourcePath = "playbook-slim\src",
    
    [Parameter(Mandatory=$false)]
    [string]$OutputFile = "EBOS-PB-1.0.0.apbx",
    
    [Parameter(Mandatory=$false)]
    [string]$Password = "malte",
    
    [Parameter(Mandatory=$false)]
    [string]$SevenZip = "C:\Program Files\NVIDIA Corporation\NVIDIA App\7z.exe"
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SourceDir = Join-Path -Path $ScriptDir -ChildPath $SourcePath
$OutputPath = Join-Path -Path $ScriptDir -ChildPath $OutputFile

if (-not (Test-Path -LiteralPath $SourceDir)) {
    Write-Error "Source directory not found: $SourceDir"
    exit 1
}

if (-not (Test-Path -LiteralPath $SevenZip)) {
    Write-Error "7z not found at: $SevenZip"
    exit 1
}

Write-Host "Building .apbx from: $SourceDir"
Write-Host "Output: $OutputPath"

& $SevenZip a -t7z $OutputPath "$SourceDir\*" -p"$Password" -mhe=on -mx=5 2>&1

if ($LASTEXITCODE -eq 0) {
    $hash = (Get-FileHash -LiteralPath $OutputPath -Algorithm SHA256).Hash.ToUpper()
    $size = (Get-Item -LiteralPath $OutputPath).Length
    Write-Host "`nBuild successful!"
    Write-Host "  Size: $size bytes ($([math]::Round($size/1MB, 2)) MB)"
    Write-Host "  SHA256: $hash"
    
    $hash | Set-Content -Path (Join-Path -Path $ScriptDir -ChildPath "SHA256.txt")
    Write-Host "  Hash saved to SHA256.txt"
} else {
    Write-Error "Build failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
}
