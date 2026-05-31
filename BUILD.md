# Build Process

## Overview

The EB Playbook is distributed as a password-protected 7z archive (`.apbx`) that is loaded by [AME Wizard](https://amelabs.net). The build process packages the playbook source, supporting executables, and the EB Tool installer into a single encrypted archive.

---

## Prerequisites

| Tool | Required for | Notes |
|------|-------------|-------|
| [7-Zip](https://7-zip.org/) (`7z.exe`) | Creating `.apbx` archive | Path may vary; default: `C:\Program Files\7-Zip\7z.exe` |
| PowerShell 5.1+ | Running build script | Ships with Windows |
| [Flutter SDK](https://flutter.dev) ^3.11.0 | Rebuilding EB Tool | Only needed when changing EB Tool source |
| [Dart SDK](https://dart.dev) ^3.11.0 | Rebuilding EB Tool CLI | Included with Flutter |
| Git | Version control | Optional for publishing |

---

## Quick Build (Playbook only)

If you only changed playbook YAML/config files (no EB Tool changes):

### Using the build script

```powershell
# From the repo root:
.\build-apbx.ps1

# Or with custom parameters:
.\build-apbx.ps1 -SourcePath "src" -OutputFile "EBOS-PB-26.06.apbx" -Password "yourpassword"
```

### Manual build

```powershell
# The optimized/ directory is the canonical build workspace:
& "C:\Program Files\7-Zip\7z.exe" a -t7z "EBOS-PB-1.0.0.apbx" "playbook-slim\src\*" -p"malte" -mhe=on -mx=5
```

### Parameters explained

| Parameter | Default | Description |
|-----------|---------|-------------|
| `-SourcePath` | `playbook-slim\src` | Directory containing the playbook files |
| `-OutputFile` | `EBOS-PB-1.0.0.apbx` | Output archive filename |
| `-Password` | `malte` | Encryption password for the archive |
| `-SevenZip` | `C:\Program Files\NVIDIA Corporation\NVIDIA App\7z.exe` | Path to 7z executable |

### Archive settings

- **Format**: 7z
- **Encryption**: AES-256 (header encryption enabled: `-mhe=on`)
- **Compression**: Normal (`-mx=5`)
- **Password**: `malte` (required by AME Wizard)

---

## Full Build (including EB Tool)

If you changed EB Tool source code or need fresh binaries:

### 1. Rebuild EB Tool GUI

```powershell
cd src\EB-tool\src
flutter pub get
flutter build windows --release
# Output: build\windows\x64\runner\Release\eb-tool.exe
```

### 2. Rebuild EB Tool CLI

```powershell
cd src\EB-tool\src
dart compile exe lib\main_cli.dart -o ..\eb-tool-cli.exe
# Output: eb-tool-cli.exe
```

### 3. Copy binaries to playbook

```powershell
Copy-Item "eb-tool.exe" "playbook-slim\src\Executables\eb-tool.exe"
Copy-Item "eb-tool-cli.exe" "playbook-slim\src\Executables\eb-tool-cli.exe"
```

### 4. Update directory structure

The playbook source layout:

```
src/
  playbook.conf          # Playbook metadata (name, version, UniqueId, etc.)
  playbook.png           # Playbook icon shown in AME Wizard
  Configuration/
    main.yml             # Task execution order
    Tasks/
      start.yml          # Initial setup, EB Tool install, power plan
      registry.yml       # Registry tweaks (includes os-info, privacy, etc.)
      services.yml       # Windows service configuration
      software.yml       # Software installation
      packages/          # App/WinSxS removal tasks
      revert.yml         # Rollback outdated changes (onUpgrade)
      final.yml          # Final cleanup and reboot
  Executables/
    eb-tool-Setup.exe    # EB Tool installer (Inno Setup)
    eb-tool.exe          # EB Tool GUI (rebuilt from source)
    eb-tool-cli.exe      # EB Tool CLI (rebuilt from source)
  Images/
    playbook.png         # Used in AME Wizard UI
```

### 5. Rebuild the archive

```powershell
.\build-apbx.ps1
```

---

## Updating the AME Wizard Cache

AME Wizard caches extracted playbooks at `%TEMP%\AME\Playbooks\<UniqueId>\`.
After rebuilding the `.apbx`, update the cache so the wizard picks up changes:

```powershell
$cache = "$env:TEMP\AME\Playbooks\5E6970A9-297F-4AFE-AF21-508854B038E1"
Remove-Item "$cache\*" -Recurse -Force
& "7z.exe" x "EBOS-PB-1.0.0.apbx" -p"malte" -o"$cache" -y
```

The `UniqueId` directory name must match the `<UniqueId>` in `playbook.conf`.

---

## GitHub Workflow (CI/CD)

The repository includes a GitHub Actions workflow (`.github/workflows/main.yml`) that:

1. Checks out the `main` branch
2. Sets the version from the current date (`YY.MM`)
3. Updates `src/playbook.conf` and `src/Executables/FINALIZE.cmd` with the version
4. Creates the `.apbx` archive with password `malte`
5. Generates a SHA256 checksum
6. Creates a GitHub Release with the archive

To trigger: Go to Actions → "Archive and Release" → Run workflow.

---

## Versioning

| Artifact | Scheme | Example |
|----------|--------|---------|
| Playbook (`playbook-26.05` branch) | `YY.MM` | `26.06` |
| Playbook (`optimized` branch) | Semver | `1.1` |
| EB Tool | Follows Git tags | `1.0.0` |
| Archive filename | `EBOS-PB-<version>.apbx` | `EBOS-PB-26.06.apbx` |

---

## Verification

After building, verify the archive:

```powershell
# List contents
& "7z.exe" l "EBOS-PB-1.0.0.apbx" -p"malte"

# Check SHA256
Get-FileHash "EBOS-PB-1.0.0.apbx" -Algorithm SHA256
```

Expected output:
- **90+ files**, 18 folders
- Password-protected with header encryption
- Contents include `playbook.conf`, `Configuration/`, `Executables/`, `Images/`
