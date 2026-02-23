<div align="center">

# ⚔️ Claude Code Sound Effects ⚔️

### *Bring the medieval battlefield to your terminal*

**Stronghold Crusader Arabian Bowman Voice Pack Included**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux%20%7C%20Windows-blue)]()
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Hooks-orange)]()

<img src="https://img.shields.io/badge/-%20DEUS%20VULT%20-red?style=for-the-badge" />

</div>

---

```
    ░██████╗░███╗░░██╗░█████╗░░█████╗░██╗░░██╗
    ██╔════╝░████╗░██║██╔══██╗██╔══██╗██║░░██║
    ██║░░██╗░██╔██╗██║██║░░██║██║░░╚═╝███████║
    ██║░░╚██╗██║╚████║██║░░██║██║░░██╗██╔══██║
    ╚██████╔╝██║░╚███║╚█████╔╝╚█████╔╝██║░░██║
    ░╚═════╝░╚═╝░░╚══╝░╚════╝░░╚════╝░╚═╝░░╚═╝
     ██████╗ ███████╗████████╗██╗  ██╗ ██████╗ ██████╗ ██████╗ 
    ██╔════╝ ██╔════╝╚══██╔══╝██║  ██║██╔═══██╗██╔══██╗██╔══██╗
    ██║  ███╗█████╗     ██║   ███████║██║   ██║██║  ██║██║  ██║
    ██║   ██║██╔══╝     ██║   ██╔══██║██║   ██║██║  ██║██║  ██║
    ╚██████╔╝███████╗   ██║   ██║  ██║╚██████╔╝██████╔╝██████╔╝
     ╚═════╝ ╚══════╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═════╝ 
```

<div align="center">

## 🏰 *Now your terminal sounds like the Holy Land, 1189 AD* 🏰

</div>

---

## 📜 The Chronicle

Remember the satisfying clash of swords, the rally of troops, and those iconic **Arabian Bowman** voice lines from *Stronghold Crusader*? 

Now every Claude Code session can feel like you're commanding your forces in the desert. Hear **"Abbas!"** when you start a session, **"We are at your service!"** when you submit a prompt, and **"Shoot!"** when Claude completes your task.

> *"For your victory!"* — Arabian Bowman, upon receiving your command

---

## ⚡ Features

| Feature | Description |
|---------|-------------|
| 🎮 **Nostalgic Audio** | Authentic Stronghold Crusader voice clips |
| 🖥️ **Cross-Platform** | macOS, Linux, Windows, WSL support |
| 🔄 **Sound Cycling** | Never hear the same quote twice in a row |
| 🛡️ **Non-Destructive** | Safely merges with existing settings |
| 🔇 **Easy Control** | Mute/unmute without uninstalling |
| 📦 **Multiple Profiles** | Switch between different sound packs |

---

## 🚀 Quick Start

### macOS / Linux / WSL

```bash
# Clone the stronghold
git clone https://github.com/abd3lraouf/claude-sounds.git
cd claude-sounds

# Deploy the troops
./install.sh

# Or scout available profiles
./install.sh --list
```

### Windows (PowerShell)

```powershell
# Clone the stronghold
git clone https://github.com/abd3lraouf/claude-sounds.git
cd claude-sounds

# Deploy the troops
.\install.ps1

# Or scout available profiles
.\install.ps1 -List
```

---

## 🔊 Audio Players

The installer automatically detects your available audio player:

| Platform | Primary | Fallbacks |
|----------|---------|-----------|
| 🍎 macOS | `afplay` | `ffplay`, `mpv` |
| 🐧 Linux | `paplay` | `aplay`, `ffplay`, `mpv` |
| 🪟 Windows | PowerShell SoundPlayer | `ffplay` |
| 🐧 WSL | Windows PowerShell (interop) | — |

### Installing Audio Players

**macOS:**
```bash
brew install ffmpeg  # or: brew install mpv
```

**Linux (Debian/Ubuntu):**
```bash
sudo apt install pipewire-pulse  # for paplay
sudo apt install alsa-utils      # for aplay  
sudo apt install ffmpeg          # for ffplay
```

---

## ⚔️ Hook Events

| Event | When It Fires | Bowman Says |
|-------|---------------|-------------|
| 🏁 `SessionStart` | New Claude Code session | *"Abbas!"*, *"We are at your service"* |
| 📝 `UserPromptSubmit` | You send a prompt | *"As you wish"*, *"Let's go"* |
| ✅ `Stop` | Claude finishes | *"Shoot!"*, *"We hunt!"*, *"Hit the target!"* |
| 🔄 `PreCompact` | Context compaction | *"Impossible!"*, *"No, I won't do this"* |

---

## 📦 Included: Arabian Bowman Voice Pack

21 authentic voice clips from **Stronghold Crusader's** Arabian Bowman unit:

<details>
<summary>🎬 <b>Click to view all quotes</b></summary>

### Session Start (Ready/Selected)
| Arabic | English |
|--------|---------|
| عباس! | Abbas! |
| نحن في خدمتك | We are at your service |
| نحن تحت أمرك | We are at your command |
| كما ترغب | As you wish |
| لنصرك! | For your victory! |
| سوف تتم | It will be done |

### Prompt Submit (Moving/Acknowledgment)
| Arabic | English |
|--------|---------|
| سنترك حالا | We are leaving now |
| هلم | Let's go |
| نزحف | We crawl |
| طريق طويل! | A long way! |

### Task Complete (Attack)
| Arabic | English |
|--------|---------|
| أطلق | Shoot |
| أطلق! | Shoot! |
| نصطاد! | We hunt! |
| نبحث عن هدف! | Looking for a target! |
| هدِّف! | Hit the target! |
| قاتل! | Fight! |

### Context Compact (Refusal/Dismissal)
| Arabic | English |
|--------|---------|
| مستحيل! | Impossible! |
| لا، لن أقوم بذلك | No, I won't do this |
| سنترك | We will leave |
| احرق! | Burn it! |

</details>

---

## 🎛️ Profile Manager

Control your sound effects:

```bash
# List all profiles
~/.claude/scripts/profile-manager.sh list

# Switch profile
~/.claude/scripts/profile-manager.sh use arabian_bowman

# Show current profile
~/.claude/scripts/profile-manager.sh current

# Mute all sounds
~/.claude/scripts/profile-manager.sh mute

# Unmute sounds
~/.claude/scripts/profile-manager.sh unmute

# Check mute status
~/.claude/scripts/profile-manager.sh status

# Test a specific hook
~/.claude/scripts/profile-manager.sh test session
```

---

## 🏗️ Adding Custom Profiles

Create your own sound packs:

```bash
# 1. Create a new profile directory
mkdir sounds/my_knight

# 2. Add audio files (.ogg, .mp3, or .wav)
cp ~/my_sounds/*.ogg sounds/my_knight/

# 3. Install the profile
./install.sh -p my_knight

# 4. Switch to it
~/.claude/scripts/profile-manager.sh use my_knight
```

---

## 🗑️ Uninstallation

### macOS / Linux / WSL

```bash
./uninstall.sh                    # Remove all profiles
./uninstall.sh -p arabian_bowman  # Remove specific profile
./uninstall.sh -k                 # Keep sounds, remove hooks only
```

### Windows

```powershell
.\uninstall.ps1                    # Remove all profiles
.\uninstall.ps1 -Profile arabian_bowman  # Remove specific profile
.\uninstall.ps1 -KeepSounds        # Keep sounds, remove hooks only
```

---

## 📁 File Structure

After installation:

```
~/.claude/
├── profiles/
│   └── arabian_bowman/
│       └── *.ogg              # Voice clips
├── scripts/
│   ├── arabian_bowman_session.sh
│   ├── arabian_bowman_prompt.sh
│   ├── arabian_bowman_stop.sh
│   ├── arabian_bowman_compact.sh
│   └── profile-manager.sh
├── .current_profile
├── .state_*                   # Sound cycling state
└── settings.json              # Hooks configured
```

---

## 🔧 Requirements

- [Claude Code CLI](https://claude.ai/code) installed
- Audio player (auto-detected)
- Bash (Unix) or PowerShell 5.1+ (Windows)

---

## 🐛 Troubleshooting

<details>
<summary><b>No sounds playing?</b></summary>

1. Check mute status:
   ```bash
   ~/.claude/scripts/profile-manager.sh status
   ```

2. Test manually:
   ```bash
   ~/.claude/scripts/profile-manager.sh test session
   ```

3. Verify audio player is installed (see [Audio Players](#-audio-players))

</details>

<details>
<summary><b>Sounds work manually but not in Claude Code?</b></summary>

1. Restart Claude Code after installation
2. Check `~/.claude/settings.json` contains the hooks section
3. Verify script paths in settings.json are correct

</details>

<details>
<summary><b>Settings.json issues?</b></summary>

Backups are created automatically:
```bash
ls ~/.claude/settings.json.backup.*
```
Restore the most recent backup if needed.

</details>

---

## 🎖️ Credits

| What | Who |
|------|-----|
| **Arabian Bowman Sounds** | Stronghold Crusader by [Firefly Studios](https://www.fireflyworlds.com/) |
| **Audio Source** | [Stronghold Wiki](https://stronghold.fandom.com/wiki/Arabian_bowman/Stronghold_Crusader/Quotes) |
| **Hook System** | [Claude Code](https://claude.ai/code) |

---

## 📜 License

MIT License - See [LICENSE](LICENSE) for details.

---

<div align="center">

### 🏰 *May your code never fall to siege* 🏰

**Stronghold Crusader** is a trademark of Firefly Studios. 
Sound files are provided for personal, non-commercial use.

---

[⬆ Back to Top](#️-claude-code-sound-effects-️)

</div>
