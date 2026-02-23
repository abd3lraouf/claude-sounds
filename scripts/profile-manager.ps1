#Requires -Version 5.1

param(
    [Parameter(Position=0)]
    [string]$Command = "",
    
    [Parameter(Position=1)]
    [string]$Argument = ""
)

$ClaudeDir = Join-Path $env:USERPROFILE ".claude"

function Write-Info { Write-Host "[INFO] $args" -ForegroundColor Blue }
function Write-Success { Write-Host "[OK] " -NoNewline; Write-Host $args -ForegroundColor Green }
function Write-Err { Write-Host "[ERROR] $args" -ForegroundColor Red }

function Show-Usage {
    @("
Usage: .\profile-manager.ps1 <command> [options]

Commands:
    list              List available profiles
    use <profile>     Switch to a profile
    current           Show current profile
    mute              Mute all sounds
    unmute            Unmute sounds
    status            Show mute status
    test <hook>       Test a hook sound (session/prompt/stop/compact)

Examples:
    .\profile-manager.ps1 use arabian_bowman
    .\profile-manager.ps1 mute
    .\profile-manager.ps1 test session
") | Write-Host
}

function Get-Profiles {
    $profilesPath = Join-Path $ClaudeDir "profiles"
    if (-not (Test-Path $profilesPath)) { return @() }
    
    Get-ChildItem $profilesPath -Directory | ForEach-Object {
        $count = (Get-ChildItem $_.FullName -Filter "*.ogg").Count
        $count += (Get-ChildItem $_.FullName -Filter "*.mp3").Count
        $count += (Get-ChildItem $_.FullName -Filter "*.wav").Count
        [PSCustomObject]@{ Name = $_.Name; Sounds = $count }
    }
}

function Show-Profiles {
    Write-Host "Available profiles:`n-------------------"
    $current = Get-CurrentProfile
    
    Get-Profiles | ForEach-Object {
        $marker = if ($_.Name -eq $current) { " (active)" } else { "" }
        Write-Host "  $($_.Name)`t($($_.Sounds) sounds)$marker"
    }
}

function Get-CurrentProfile {
    $file = Join-Path $ClaudeDir ".current_profile"
    if (Test-Path $file) {
        return Get-Content $file
    }
    return "none"
}

function Use-Profile {
    param([string]$ProfileName)
    
    if (-not $ProfileName) {
        Write-Err "Please specify a profile name"
        Show-Profiles
        exit 1
    }
    
    $profileDir = Join-Path $ClaudeDir "profiles\$ProfileName"
    if (-not (Test-Path $profileDir)) {
        Write-Err "Profile '$ProfileName' not found"
        Show-Profiles
        exit 1
    }
    
    $ProfileName | Out-File (Join-Path $ClaudeDir ".current_profile") -NoNewline
    Write-Success "Switched to profile: $ProfileName"
}

function Set-Mute {
    param([bool]$Mute)
    
    $scriptsDir = Join-Path $ClaudeDir "scripts"
    $hooks = @("session", "prompt", "stop", "compact")
    $profiles = Get-Profiles
    
    foreach ($profile in $profiles) {
        foreach ($hook in $hooks) {
            $script = Join-Path $scriptsDir "$($profile.Name)_${hook}.ps1"
            if (Test-Path $script) {
                $content = Get-Content $script -Raw
                
                if ($Mute) {
                    if ($content -notmatch "# MUTED") {
                        $content = $content -replace 'function Play-Sound \{', 'function Play-Sound { return # MUTED'
                        Set-Content $script $content -NoNewline
                    }
                } else {
                    $content = $content -replace 'return # MUTED', ''
                    Set-Content $script $content -NoNewline
                }
            }
        }
    }
    
    if ($Mute) {
        "muted" | Out-File (Join-Path $ClaudeDir ".mute_status") -NoNewline
        Write-Success "Sounds muted"
    } else {
        Remove-Item (Join-Path $ClaudeDir ".mute_status") -ErrorAction SilentlyContinue
        Write-Success "Sounds unmuted"
    }
}

function Get-Status {
    if (Test-Path (Join-Path $ClaudeDir ".mute_status")) {
        Write-Host "muted"
    } else {
        Write-Host "unmuted"
    }
}

function Test-HookSound {
    param([string]$Hook)
    
    $profile = Get-CurrentProfile
    if ($profile -eq "none") {
        Write-Err "No profile active"
        exit 1
    }
    
    $Hook = if ($Hook) { $Hook.ToLower() } else { "session" }
    
    if ($Hook -notin @("session", "prompt", "stop", "compact")) {
        Write-Err "Invalid hook: $Hook"
        Write-Host "Valid hooks: session, prompt, stop, compact"
        exit 1
    }
    
    $script = Join-Path $ClaudeDir "scripts\${profile}_${Hook}.ps1"
    if (-not (Test-Path $script)) {
        Write-Err "Hook script not found: $Hook"
        exit 1
    }
    
    Write-Info "Testing $Hook hook..."
    & $script
}

# Main
switch ($Command.ToLower()) {
    "list" { Show-Profiles }
    "use" { Use-Profile $Argument }
    "current" { Write-Host (Get-CurrentProfile) }
    "mute" { Set-Mute $true }
    "unmute" { Set-Mute $false }
    "status" { Get-Status }
    "test" { Test-HookSound $Argument }
    { $_ -in @("-h", "--help", "help", "") } { Show-Usage }
    default { Write-Err "Unknown command: $Command"; Show-Usage; exit 1 }
}
