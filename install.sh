#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR"

source "$REPO_DIR/lib/common.sh"
source "$REPO_DIR/lib/audio.sh"
source "$REPO_DIR/lib/settings.sh"

DEFAULT_PROFILE="arabian_bowman"

usage() {
  echo "Usage: $0 [OPTIONS]"
  echo ""
  echo "Install Claude Code sound effects with hook integration."
  echo ""
  echo "Options:"
  echo "  -p, --profile NAME   Profile to install (default: $DEFAULT_PROFILE)"
  echo "  -d, --dir DIR        Custom installation directory (default: ~/.claude)"
  echo "  -l, --list           List available profiles"
  echo "  -h, --help           Show this help message"
  echo ""
  echo "Examples:"
  echo "  $0                           # Install default profile"
  echo "  $0 -p arabian_bowman         # Install specific profile"
  echo "  $0 -l                        # List available profiles"
}

list_profiles() {
  echo "Available profiles:"
  echo ""
  for dir in "$REPO_DIR/sounds"/*/; do
    if [ -d "$dir" ]; then
      local name=$(basename "$dir")
      local count=$(find "$dir" -name "*.ogg" -o -name "*.mp3" -o -name "*.wav" 2>/dev/null | wc -l | tr -d ' ')
      printf "  %-20s (%d sounds)\n" "$name" "$count"
    fi
  done
}

validate_profile() {
  local profile="$1"
  if [ ! -d "$REPO_DIR/sounds/$profile" ]; then
    error "Profile '$profile' not found!"
    echo ""
    list_profiles
    exit 1
  fi
  
  local count=$(find "$REPO_DIR/sounds/$profile" \( -name "*.ogg" -o -name "*.mp3" -o -name "*.wav" \) 2>/dev/null | wc -l | tr -d ' ')
  if [ "$count" -eq 0 ]; then
    error "Profile '$profile' has no audio files!"
    exit 1
  fi
}

install_profile() {
  local profile="$1"
  local claude_dir="$2"
  
  validate_profile "$profile"
  
  local profiles_dir="$claude_dir/profiles"
  local scripts_dir="$claude_dir/scripts"
  local profile_dir="$profiles_dir/$profile"
  
  info "Installing profile: $profile"
  
  mkdir -p "$profiles_dir"
  mkdir -p "$scripts_dir"
  
  if [ -d "$profile_dir" ]; then
    warn "Profile directory already exists, backing up..."
    mv "$profile_dir" "${profile_dir}.backup.$(date +%Y%m%d_%H%M%S)"
  fi
  
  mkdir -p "$profile_dir"
  
  info "Copying sound files..."
  cp -r "$REPO_DIR/sounds/$profile"/* "$profile_dir/"
  local sound_count=$(find "$profile_dir" -type f | wc -l | tr -d ' ')
  success "Copied $sound_count sound files"
  
  if ! check_audio_dependencies; then
    error "Cannot continue without audio player"
    exit 1
  fi
  
  local play_cmd=$(get_play_command)
  if [ -z "$play_cmd" ]; then
    error "Could not determine play command"
    exit 1
  fi
  
  info "Generating hook scripts..."
  
  local sounds_session=$(find "$profile_dir" -name "*.ogg" -o -name "*.mp3" -o -name "*.wav" | sort | head -6 | xargs -I{} basename {})
  local sounds_prompt=$(find "$profile_dir" -name "*.ogg" -o -name "*.mp3" -o -name "*.wav" | sort | tail -n +7 | head -6 | xargs -I{} basename {})
  local sounds_stop=$(find "$profile_dir" -name "*.ogg" -o -name "*.mp3" -o -name "*.wav" | sort | tail -n +13 | head -6 | xargs -I{} basename {})
  local sounds_compact=$(find "$profile_dir" -name "*.ogg" -o -name "*.mp3" -o -name "*.wav" | sort | tail -n +19 | xargs -I{} basename {})
  
  for hook in session prompt stop compact; do
    local sounds_var="sounds_$hook"
    local sounds="${!sounds_var}"
    
    local hook_script="$scripts_dir/${profile}_${hook}.sh"
    
    local sounds_array=""
    for sound in $sounds; do
      sounds_array+="  \"$sound\"\n"
    done
    
    if [ -z "$sounds_array" ]; then
      sounds_array="  \"$(ls "$profile_dir" | head -1)\"\n"
    fi
    
    python3 -c "
import re
with open('$REPO_DIR/scripts/hook.sh', 'r') as f:
    content = f.read()

content = content.replace('__PROFILE__', '$profile')
content = content.replace('__HOOK__', '$hook')
content = content.replace('__SOUNDS_DIR__', '$profile_dir')
content = content.replace('__PLAY_CMD__', '''$play_cmd''')

sounds = '''$sounds_array'''
sounds = sounds.rstrip('\\n')
content = re.sub(r'__SOUNDS__', sounds.rstrip(), content)

with open('$hook_script', 'w') as f:
    f.write(content)
"
    
    chmod +x "$hook_script"
  done
  
  success "Generated 4 hook scripts"
  
  cp "$REPO_DIR/scripts/profile-manager.sh" "$scripts_dir/profile-manager.sh" 2>/dev/null || true
  chmod +x "$scripts_dir/profile-manager.sh" 2>/dev/null || true
  
  local settings_file="$claude_dir/settings.json"
  
  if [ -f "$settings_file" ]; then
    info "Backing up settings.json..."
    local backup=$(backup_file "$settings_file")
    success "Backup created: $backup"
  fi
  
  info "Merging hooks into settings.json..."
  if merge_hooks "$settings_file" "$profile" "$scripts_dir"; then
    success "Hooks configured successfully"
  else
    error "Failed to merge hooks"
    exit 1
  fi
  
  echo "$profile" > "$claude_dir/.current_profile"
  
  echo ""
  echo "  ═════════════════════════════════════════════"
  success "Installation complete!"
  echo "  ═════════════════════════════════════════════"
  echo ""
  echo "  🏰 Profile:     $profile"
  echo "  📦 Sounds:      $sound_count files"
  echo "  📁 Location:    $profile_dir"
  echo "  📜 Scripts:     $scripts_dir/${profile}_*.sh"
  echo ""
  echo "  ─────────────────────────────────────────────"
  echo "  Commands:"
  echo "  ─────────────────────────────────────────────"
  echo "  Mute:     $scripts_dir/profile-manager.sh mute"
  echo "  Unmute:   $scripts_dir/profile-manager.sh unmute"
  echo "  Status:   $scripts_dir/profile-manager.sh status"
  echo ""
  echo "  ⚔️  Restart Claude Code to activate!  ⚔️"
  echo ""
}

main() {
  local profile="$DEFAULT_PROFILE"
  local claude_dir=""
  
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -p|--profile)
        profile="$2"
        shift 2
        ;;
      -d|--dir)
        claude_dir="$2"
        shift 2
        ;;
      -l|--list)
        list_profiles
        exit 0
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        error "Unknown option: $1"
        usage
        exit 1
        ;;
    esac
  done
  
  if [ -z "$claude_dir" ]; then
    claude_dir=$(get_claude_dir)
  fi
  
  echo ""
  echo "    ░██████╗░███╗░░██╗░█████╗░░█████╗░██╗░░██╗"
  echo "    ██╔════╝░████╗░██║██╔══██╗██╔══██╗██║░░██║"
  echo "    ██║░░██╗░██╔██╗██║██║░░██║██║░░╚═╝███████║"
  echo "    ██║░░╚██╗██║╚████║██║░░██║██║░░██╗██╔══██║"
  echo "    ╚██████╔╝██║░╚███║╚█████╔╝╚█████╔╝██║░░██║"
  echo "    ░╚═════╝░╚═╝░░╚══╝░╚════╝░░╚════╝░╚═╝░░╚═╝"
  echo ""
  echo "    ⚔️  CLAUDE CODE SOUND EFFECTS INSTALLER  ⚔️"
  echo ""
  echo "           \"For your victory!\""
  echo ""
  info "Detected OS: $(detect_os)"
  info "Target directory: $claude_dir"
  echo ""
  
  install_profile "$profile" "$claude_dir"
}

main "$@"
