#Requires -Version 5.1

param(
    [string]$Profile = "arabian_bowman",
    [string]$ClaudeDir = "",
    [switch]$List,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoDir = Split-Path -Parent $ScriptDir

function Write-Info { Write-Host "[INFO] $args" -ForegroundColor Blue }
function Write-Success { Write-Host "[OK] $args" -ForegroundColor Green }
function Write-Warn { Write-Host "[WARN] $args" -ForegroundColor Yellow }
function Write-Err { Write-Host "[ERROR] $args" -ForegroundColor Red }

function Show-Usage {
    @("
Usage: .\install.ps1 [OPTIONS]

Install Claude Code sound effects with hook integration.

Options:
    -Profile NAME       Profile to install (default: arabian_bowman)
    -ClaudeDir DIR      Custom installation directory (default: ~/.claude)
    -List               List available profiles
    -Help               Show this help message

Examples:
    .\install.ps1                        # Install default profile
    .\install.ps1 -Profile arabian_bowman
    .\install.ps1 -List
") | Write-Host
}

function Get-ClaudeDir {
    if ($ClaudeDir) { return $ClaudeDir }
    return Join-Path $env:USERPROFILE ".claude"
}

function Get-Profiles {
    Get-ChildItem -Path (Join-Path $RepoDir "sounds") -Directory | ForEach-Object {
        $count = (Get-ChildItem -Path $_.FullName -Filter "*.ogg" -ErrorAction SilentlyContinue).Count
        $count += (Get-ChildItem -Path $_.FullName -Filter "*.mp3" -ErrorAction SilentlyContinue).Count
        $count += (Get-ChildItem -Path $_.FullName -Filter "*.wav" -ErrorAction SilentlyContinue).Count
        [PSCustomObject]@{ Name = $_.Name; Sounds = $count }
    }
}

function Show-Profiles {
    Write-Host "Available profiles:`n"
    Get-Profiles | ForEach-Object {
        Write-Host "  $($_.Name)`t($($_.Sounds) sounds)"
    }
}

function Test-AudioPlayer {
    $players = @("powershell")
    
    foreach ($player in $players) {
        try {
            $null = Get-Command $player -ErrorAction Stop
            Write-Success "Audio player available: $player"
            return $true
        } catch {}
    }
    
    Write-Err "No audio player found!"
    return $false
}

function New-HookScript {
    param(
        [string]$ProfileName,
        [string]$HookType,
        [string]$SoundsDir,
        [string]$OutputPath,
        [string[]]$Sounds
    )
    
    $soundsArray = $Sounds | ForEach-Object { "    `"$_`"" }
    $soundsStr = $soundsArray -join ",`n"
    
    $script = @"
# Claude Code Sound Hook - $HookType
# Profile: $ProfileName

param()

`$SoundsDir = "$SoundsDir"
`$StateFile = Join-Path `$env:USERPROFILE ".claude\.state_${ProfileName}_${HookType}"
`$Sounds = @(
$soundsStr
)

function Play-Sound {
    param([string]`$SoundFile)
    
    if (Test-Path `$SoundFile) {
        `$player = New-Object System.Media.SoundPlayer `$SoundFile
        `$player.Play()
    }
}

function Main {
    if (`$Sounds.Count -eq 0) { return }
    
    `$index = 0
    if (Test-Path `$StateFile) {
        `$index = [int](Get-Content `$StateFile)
    }
    
    if (`$index -ge `$Sounds.Count -or `$index -lt 0) {
        `$index = 0
    }
    
    `$soundFile = Join-Path `$SoundsDir `$Sounds[`$index]
    Play-Sound `$soundFile
    
    `$nextIndex = (`$index + 1) % `$Sounds.Count
    Set-Content -Path `$StateFile -Value `$nextIndex -NoNewline
}

Main
"@
    
    $script | Out-File -FilePath $OutputPath -Encoding UTF8
    Write-Success "Created: $HookType hook script"
}

function Install-Profile {
    param(
        [string]$ProfileName,
        [string]$TargetDir
    )
    
    $sourceProfileDir = Join-Path $RepoDir "sounds\$ProfileName"
    
    if (-not (Test-Path $sourceProfileDir)) {
        Write-Err "Profile '$ProfileName' not found!"
        Show-Profiles
        exit 1
    }
    
    $profilesDir = Join-Path $TargetDir "profiles"
    $scriptsDir = Join-Path $TargetDir "scripts"
    $profileDir = Join-Path $profilesDir $ProfileName
    $settingsFile = Join-Path $TargetDir "settings.json"
    
    Write-Info "Installing profile: $ProfileName"
    
    # Create directories
    New-Item -ItemType Directory -Force -Path $profilesDir | Out-Null
    New-Item -ItemType Directory -Force -Path $scriptsDir | Out-Null
    
    # Copy sounds
    if (Test-Path $profileDir) {
        Write-Warn "Profile directory exists, backing up..."
        $backup = "$profileDir.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Move-Item $profileDir $backup
    }
    
    New-Item -ItemType Directory -Force -Path $profileDir | Out-Null
    Copy-Item -Path "$sourceProfileDir\*" -Destination $profileDir -Recurse
    
    $soundCount = (Get-ChildItem $profileDir -Filter "*.ogg").Count
    $soundCount += (Get-ChildItem $profileDir -Filter "*.mp3").Count
    $soundCount += (Get-ChildItem $profileDir -Filter "*.wav").Count
    Write-Success "Copied $soundCount sound files"
    
    if (-not (Test-AudioPlayer)) {
        exit 1
    }
    
    # Get sounds for each hook
    $allSounds = Get-ChildItem $profileDir -Filter "*.ogg" | Sort-Object Name | Select-Object -ExpandProperty Name
    $allSounds += Get-ChildItem $profileDir -Filter "*.mp3" | Sort-Object Name | Select-Object -ExpandProperty Name
    $allSounds += Get-ChildItem $profileDir -Filter "*.wav" | Sort-Object Name | Select-Object -ExpandProperty Name
    
    $sessionSounds = $allSounds | Select-Object -First 6
    $promptSounds = $allSounds | Select-Object -Skip 6 -First 6
    $stopSounds = $allSounds | Select-Object -Skip 12 -First 6
    $compactSounds = $allSounds | Select-Object -Skip 18
    
    # Generate hook scripts
    Write-Info "Generating hook scripts..."
    
    New-HookScript -ProfileName $ProfileName -HookType "session" -SoundsDir $profileDir -OutputPath (Join-Path $scriptsDir "${ProfileName}_session.ps1") -Sounds $sessionSounds
    New-HookScript -ProfileName $ProfileName -HookType "prompt" -SoundsDir $profileDir -OutputPath (Join-Path $scriptsDir "${ProfileName}_prompt.ps1") -Sounds $promptSounds
    New-HookScript -ProfileName $ProfileName -HookType "stop" -SoundsDir $profileDir -OutputPath (Join-Path $scriptsDir "${ProfileName}_stop.ps1") -Sounds $stopSounds
    New-HookScript -ProfileName $ProfileName -HookType "compact" -SoundsDir $profileDir -OutputPath (Join-Path $scriptsDir "${ProfileName}_compact.ps1") -Sounds $compactSounds
    
    # Backup and update settings
    if (Test-Path $settingsFile) {
        Write-Info "Backing up settings.json..."
        Copy-Item $settingsFile "$settingsFile.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        $settings = Get-Content $settingsFile | ConvertFrom-Json
    } else {
        $settings = @{}
    }
    
    Write-Info "Merging hooks into settings.json..."
    
    $hooks = @{
        SessionStart = @(@{
            matcher = "startup|clear"
            hooks = @(@{
                type = "command"
                command = "powershell -ExecutionPolicy Bypass -File `"$scriptsDir\${ProfileName}_session.ps1`""
            })
        })
        UserPromptSubmit = @(@{
            hooks = @(@{
                type = "command"
                command = "powershell -ExecutionPolicy Bypass -File `"$scriptsDir\${ProfileName}_prompt.ps1`""
            })
        })
        Stop = @(@{
            hooks = @(@{
                type = "command"
                command = "powershell -ExecutionPolicy Bypass -File `"$scriptsDir\${ProfileName}_stop.ps1`""
            })
        })
        PreCompact = @(@{
            hooks = @(@{
                type = "command"
                command = "powershell -ExecutionPolicy Bypass -File `"$scriptsDir\${ProfileName}_compact.ps1`""
            })
        })
    }
    
    if (-not $settings.hooks) {
        $settings | Add-Member -NotePropertyName "hooks" -NotePropertyValue $hooks -Force
    } else {
        foreach ($key in $hooks.Keys) {
            if (-not $settings.hooks.$key) {
                $settings.hooks | Add-Member -NotePropertyName $key -NotePropertyValue $hooks[$key] -Force
            }
        }
    }
    
    $settings | ConvertTo-Json -Depth 10 | Set-Content $settingsFile
    Write-Success "Hooks configured"
    
    # Save current profile
    $ProfileName | Out-File -FilePath (Join-Path $TargetDir ".current_profile") -NoNewline
    
    # Copy profile manager
    $pmSource = Join-Path $RepoDir "scripts\profile-manager.ps1"
    if (Test-Path $pmSource) {
        Copy-Item $pmSource (Join-Path $scriptsDir "profile-manager.ps1") -Force
    }
    
    Write-Host "`n  ═════════════════════════════════════════════" -ForegroundColor Green
    Write-Success "Installation complete!"
    Write-Host "  ═════════════════════════════════════════════`n"
    Write-Host "  🏰 Profile:     $ProfileName"
    Write-Host "  📦 Sounds:      $soundCount files"
    Write-Host "  📁 Location:    $profileDir"
    Write-Host "  📜 Scripts:     $scriptsDir\${ProfileName}_*.ps1`n"
    Write-Host "  ⚔️  Restart Claude Code to activate!  ⚔️`n"
}

# Main
if ($Help) { Show-Usage; exit 0 }
if ($List) { Show-Profiles; exit 0 }

Write-Host ""
Write-Host "    ░██████╗░███╗░░██╗░█████╗░░█████╗░██╗░░██╗" -ForegroundColor Cyan
Write-Host "    ██╔════╝░████╗░██║██╔══██╗██╔══██╗██║░░██║" -ForegroundColor Cyan
Write-Host "    ██║░░██╗░██╔██╗██║██║░░██║██║░░╚═╝███████║" -ForegroundColor Cyan
Write-Host "    ██║░░╚██╗██║╚████║██║░░██║██║░░██╗██╔══██║" -ForegroundColor Cyan
Write-Host "    ╚██████╔╝██║░╚███║╚█████╔╝╚█████╔╝██║░░██║" -ForegroundColor Cyan
Write-Host "    ░╚═════╝░╚═╝░░╚══╝░╚════╝░░╚════╝░╚═╝░░╚═╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "    ⚔️  CLAUDE CODE SOUND EFFECTS INSTALLER  ⚔️" -ForegroundColor Yellow
Write-Host ""
Write-Host "           `"For your victory!`"" -ForegroundColor DarkYellow
Write-Host ""

Write-Info "Detected OS: Windows"
Write-Info "Target directory: $(Get-ClaudeDir)`n"

Install-Profile -ProfileName $Profile -TargetDir (Get-ClaudeDir)
