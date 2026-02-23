# Claude Code Sound Effects

Add custom sound effects to Claude Code with hook integration. Features Stronghold Crusader's Arabian Bowman quotes as the default profile.

## Features

- **Cross-platform support**: macOS, Linux, Windows, and WSL
- **Multiple profiles**: Switch between different sound packs
- **Cycling sounds**: Never hear the same sound twice in a row
- **Non-destructive**: Merges with existing Claude Code settings
- **Easy management**: Mute/unmute without uninstalling

## Quick Start

### macOS / Linux / WSL

```bash
# Clone the repository
git clone https://github.com/abd3lraouf/claude-sounds.git
cd claude-sounds

# Install with default profile
./install.sh

# Or list available profiles first
./install.sh --list
```

### Windows (PowerShell)

```powershell
# Clone the repository
git clone https://github.com/abd3lraouf/claude-sounds.git
cd claude-sounds

# Install with default profile
.\install.ps1

# Or list available profiles first
.\install.ps1 -List
```

## Audio Players

The installer automatically detects the best available audio player:

| Platform | Primary | Fallbacks |
|----------|---------|-----------|
| macOS | `afplay` | `ffplay`, `mpv` |
| Linux | `paplay` | `aplay`, `ffplay`, `mpv` |
| Windows | PowerShell SoundPlayer | `ffplay` |
| WSL | Windows PowerShell via interop | - |

### Installing Audio Players (if needed)

**macOS:**
```bash
brew install ffmpeg  # or mpv
```

**Linux (Debian/Ubuntu):**
```bash
sudo apt install pipewire-pulse  # for paplay
# or
sudo apt install alsa-utils      # for aplay
# or
sudo apt install ffmpeg          # for ffplay
```

## Usage

### Profile Manager

After installation, use the profile manager to control sounds:

**macOS / Linux / WSL:**
```bash
~/.claude/scripts/profile-manager.sh list        # List profiles
~/.claude/scripts/profile-manager.sh use <name>  # Switch profile
~/.claude/scripts/profile-manager.sh current     # Show current
~/.claude/scripts/profile-manager.sh mute        # Mute sounds
~/.claude/scripts/profile-manager.sh unmute      # Unmute sounds
~/.claude/scripts/profile-manager.sh status      # Show mute status
~/.claude/scripts/profile-manager.sh test session  # Test a sound
```

**Windows:**
```powershell
~/.claude/scripts/profile-manager.ps1 list
~/.claude/scripts/profile-manager.ps1 use <name>
~/.claude/scripts/profile-manager.ps1 mute
~/.claude/scripts/profile-manager.ps1 unmute
```

### Hook Events

Sounds are triggered on these Claude Code events:

| Event | Description | Default Sounds |
|-------|-------------|----------------|
| `SessionStart` | New Claude Code session | Ready/selected responses |
| `UserPromptSubmit` | After you send a prompt | Movement/acknowledgment |
| `Stop` | Claude finishes responding | Attack sounds |
| `PreCompact` | Before context compaction | Refusal/impossible sounds |

## Included Profiles

### Arabian Bowman (Stronghold Crusader)

21 authentic voice clips from Stronghold Crusader's Arabian Bowman unit:

- **Session**: "Abbas!", "We are at your service", "We are at your command", etc.
- **Prompt**: "We are leaving now", "Let's go", "We crawl", etc.
- **Stop**: "Shoot!", "We hunt!", "Looking for a target!", etc.
- **Compact**: "Impossible!", "No, I won't do this", "We will leave"

## Adding Custom Profiles

1. Create a new directory in `sounds/`:
   ```bash
   mkdir sounds/my_custom_sounds
   ```

2. Add audio files (`.ogg`, `.mp3`, or `.wav`):
   ```bash
   cp ~/my_sounds/*.ogg sounds/my_custom_sounds/
   ```

3. Install the new profile:
   ```bash
   ./install.sh -p my_custom_sounds
   ```

## Uninstallation

### macOS / Linux / WSL

```bash
./uninstall.sh              # Remove all profiles
./uninstall.sh -p arabian_bowman  # Remove specific profile
./uninstall.sh -k           # Keep sounds, only remove hooks
```

### Windows

```powershell
.\uninstall.ps1                    # Remove all profiles
.\uninstall.ps1 -Profile arabian_bowman  # Remove specific profile
.\uninstall.ps1 -KeepSounds        # Keep sounds, only remove hooks
```

## File Structure

After installation:

```
~/.claude/
├── profiles/
│   └── arabian_bowman/     # Sound files
│       └── *.ogg
├── scripts/
│   ├── arabian_bowman_session.sh   # Hook scripts
│   ├── arabian_bowman_prompt.sh
│   ├── arabian_bowman_stop.sh
│   ├── arabian_bowman_compact.sh
│   └── profile-manager.sh          # Management tool
├── .current_profile        # Active profile name
├── .state_*                # Sound cycling state
└── settings.json           # Updated with hooks
```

## Requirements

- Claude Code CLI installed
- One of the supported audio players
- Bash (Unix) or PowerShell 5.1+ (Windows)

## Troubleshooting

### No sounds playing

1. Check mute status: `~/.claude/scripts/profile-manager.sh status`
2. Verify audio player: The installer checks for compatible players
3. Test manually: `~/.claude/scripts/profile-manager.sh test session`

### Sounds playing but not in Claude Code

1. Restart Claude Code after installation
2. Check `~/.claude/settings.json` contains the hooks section
3. Verify hook script paths are correct

### Settings.json corrupted

Backup files are created automatically:
```bash
ls ~/.claude/settings.json.backup.*
```

Restore from backup if needed.

## Credits

- Arabian Bowman sounds: Stronghold Crusader by Firefly Studios
- Audio extracted from [Stronghold Wiki](https://stronghold.fandom.com/wiki/Arabian_bowman/Stronghold_Crusader/Quotes)

## License

MIT License - See [LICENSE](LICENSE) for details.

The included sound files are from Stronghold Crusader and are provided for personal use. Stronghold Crusader is a trademark of Firefly Studios.
