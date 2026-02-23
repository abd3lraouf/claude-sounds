#Requires -Version 5.1

param(
    [string]$Profile = "",
    [switch]$KeepSounds,
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
Usage: .\uninstall.ps1 [OPTIONS]

Uninstall Claude Code sound effects.

Options:
    -Profile NAME       Profile to uninstall (default: all)
    -KeepSounds         Keep sound files, only remove hooks
    -Help               Show this help message
") | Write-Host
}

function Get-ClaudeDir {
    return Join-Path $env:USERPROFILE ".claude"
}

function Uninstall-Profile {
    param(
        [string]$ProfileName,
        [bool]$Keep
    )
    
    $claudeDir = Get-ClaudeDir
    $profilesDir = Join-Path $claudeDir "profiles"
    $scriptsDir = Join-Path $claudeDir "scripts"
    $settingsFile = Join-Path $claudeDir "settings.json"
    
    Write-Info "Uninstalling Claude Code sound effects..."
    
    if ($ProfileName) {
        Write-Info "Removing profile: $ProfileName"
        
        $profileDir = Join-Path $profilesDir $ProfileName
        if ((Test-Path $profileDir) -and -not $Keep) {
            Remove-Item $profileDir -Recurse -Force
            Write-Success "Removed sound files"
        }
        
        $hooks = @("session", "prompt", "stop", "compact")
        foreach ($hook in $hooks) {
            $script = Join-Path $scriptsDir "${ProfileName}_${hook}.ps1"
            if (Test-Path $script) {
                Remove-Item $script -Force
            }
        }
        Write-Success "Removed hook scripts"
        
        # Remove from settings
        if (Test-Path $settingsFile) {
            Write-Info "Removing hooks from settings.json..."
            $settings = Get-Content $settingsFile | ConvertFrom-Json
            
            if ($settings.hooks) {
                $pattern = "${ProfileName}_(session|prompt|stop|compact)\.ps1"
                
                foreach ($event in @("SessionStart", "UserPromptSubmit", "Stop", "PreCompact")) {
                    if ($settings.hooks.$event) {
                        $settings.hooks.$event = @($settings.hooks.$event | Where-Object {
                            $_.hooks -and $_.hooks | Where-Object {
                                $_.command -and $_.command -notmatch $pattern
                            }
                        })
                    }
                }
                
                $settings | ConvertTo-Json -Depth 10 | Set-Content $settingsFile
                Write-Success "Hooks removed"
            }
        }
    } else {
        if ((Test-Path $profilesDir) -and -not $Keep) {
            Remove-Item $profilesDir -Recurse -Force
            Write-Success "Removed all profiles"
        }
        
        if (Test-Path $scriptsDir) {
            Get-ChildItem $scriptsDir -Filter "*_*.ps1" | Remove-Item -Force
            Write-Success "Removed hook scripts"
        }
        
        if (Test-Path $settingsFile) {
            Write-Info "Removing all hooks from settings.json..."
            $settings = Get-Content $settingsFile | ConvertFrom-Json
            if ($settings.hooks) {
                $settings.PSObject.Properties.Remove("hooks")
                $settings | ConvertTo-Json -Depth 10 | Set-Content $settingsFile
            }
            Write-Success "All hooks removed"
        }
        
        # Clean up state files
        Get-ChildItem $claudeDir -Filter ".state_*" -ErrorAction SilentlyContinue | Remove-Item -Force
        Remove-Item (Join-Path $claudeDir ".current_profile") -ErrorAction SilentlyContinue
        Remove-Item (Join-Path $claudeDir ".mute_status") -ErrorAction SilentlyContinue
    }
    
    Write-Success "Uninstall complete!"
}

if ($Help) { Show-Usage; exit 0 }

Uninstall-Profile -ProfileName $Profile -Keep $KeepSounds
