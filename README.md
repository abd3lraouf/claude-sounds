<div align="center">

<img src="https://upload.wikimedia.org/wikipedia/en/9/9c/Crusadercover.jpg" alt="Stronghold Crusader Cover" width="300">

# ⚔️ Claude Code Sound Effects ⚔️

### *Bring the medieval battlefield to your terminal*

**Stronghold Crusader Arabian Bowman Voice Pack**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux%20%7C%20Windows-blue)]()
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Hooks-orange)]()

</div>

---

## 🚀 Install

**macOS / Linux / WSL:**
```bash
git clone https://github.com/abd3lraouf/claude-sounds.git
cd claude-sounds && ./install.sh
```

**Windows (PowerShell):**
```powershell
git clone https://github.com/abd3lraouf/claude-sounds.git
cd claude-sounds; .\install.ps1
```

## 🎮 Usage

```bash
~/.claude/scripts/profile-manager.sh mute      # Mute sounds
~/.claude/scripts/profile-manager.sh unmute    # Unmute
~/.claude/scripts/profile-manager.sh test session  # Test
```

## 🔊 Hook Events

| Event | When | Bowman Says |
|-------|------|-------------|
| `SessionStart` | New session | *"Abbas!"*, *"We are at your service"* |
| `UserPromptSubmit` | Send prompt | *"As you wish"*, *"Let's go"* |
| `Stop` | Task done | *"Shoot!"*, *"We hunt!"* |
| `PreCompact` | Compact | *"Impossible!"* |

## 🗑️ Uninstall

```bash
./uninstall.sh    # Unix
.\uninstall.ps1   # Windows
```

---

<div align="center">

*Stronghold Crusader is a trademark of Firefly Studios*

**[GitHub](https://github.com/abd3lraouf/claude-sounds)**

</div>
