#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

usage() {
  echo "Usage: $(basename "$0") <command> [options]"
  echo ""
  echo "Commands:"
  echo "  list              List available profiles"
  echo "  use <profile>     Switch to a profile"
  echo "  current           Show current profile"
  echo "  mute              Mute all sounds"
  echo "  unmute            Unmute sounds"
  echo "  status            Show mute status"
  echo "  test [hook]       Test a hook sound (session/prompt/stop/compact)"
  echo ""
  echo "Examples:"
  echo "  $(basename "$0") use arabian_bowman"
  echo "  $(basename "$0") mute"
  echo "  $(basename "$0") test session"
}

list_profiles() {
  echo "Available profiles:"
  echo "-------------------"
  for dir in "$CLAUDE_DIR/profiles"/*/; do
    if [ -d "$dir" ]; then
      local name=$(basename "$dir")
      local count=$(find "$dir" -type f \( -name "*.ogg" -o -name "*.mp3" -o -name "*.wav" \) 2>/dev/null | wc -l | tr -d ' ')
      local current=""
      if [ -f "$CLAUDE_DIR/.current_profile" ] && [ "$(cat $CLAUDE_DIR/.current_profile)" = "$name" ]; then
        current=" (active)"
      fi
      printf "  %-20s %d sounds%s\n" "$name" "$count" "$current"
    fi
  done
}

current_profile() {
  if [ -f "$CLAUDE_DIR/.current_profile" ]; then
    cat "$CLAUDE_DIR/.current_profile"
  else
    echo "none"
  fi
}

switch_profile() {
  local profile="$1"
  local profile_dir="$CLAUDE_DIR/profiles/$profile"
  
  if [ -z "$profile" ]; then
    error "Please specify a profile name"
    list_profiles
    exit 1
  fi
  
  if [ ! -d "$profile_dir" ]; then
    error "Profile '$profile' not found"
    list_profiles
    exit 1
  fi
  
  echo "$profile" > "$CLAUDE_DIR/.current_profile"
  success "Switched to profile: $profile"
}

mute() {
  for script in "$CLAUDE_DIR/scripts"/*_session.sh \
                "$CLAUDE_DIR/scripts"/*_prompt.sh \
                "$CLAUDE_DIR/scripts"/*_stop.sh \
                "$CLAUDE_DIR/scripts"/*_compact.sh; do
    if [ -f "$script" ]; then
      if grep -q "^#MUTED# " "$script"; then
        continue
      fi
      sed -i.bak 's|^play_sound() {|play_sound() {\n  return 0; #MUTED|' "$script" 2>/dev/null || \
      sed -i '' 's|^play_sound() {|play_sound() {\n  return 0; #MUTED|' "$script"
      rm -f "${script}.bak"
    fi
  done
  echo "muted" > "$CLAUDE_DIR/.mute_status"
  success "Sounds muted"
}

unmute() {
  for script in "$CLAUDE_DIR/scripts"/*_session.sh \
                "$CLAUDE_DIR/scripts"/*_prompt.sh \
                "$CLAUDE_DIR/scripts"/*_stop.sh \
                "$CLAUDE_DIR/scripts"/*_compact.sh; do
    if [ -f "$script" ]; then
      sed -i.bak '/#MUTED/d' "$script" 2>/dev/null || \
      sed -i '' '/#MUTED/d' "$script"
      rm -f "${script}.bak"
    fi
  done
  rm -f "$CLAUDE_DIR/.mute_status"
  success "Sounds unmuted"
}

status() {
  if [ -f "$CLAUDE_DIR/.mute_status" ]; then
    echo "muted"
  else
    echo "unmuted"
  fi
}

test_hook() {
  local hook="${1:-session}"
  local profile=$(current_profile)
  
  if [ "$profile" = "none" ]; then
    error "No profile active"
    exit 1
  fi
  
  local script="$CLAUDE_DIR/scripts/${profile}_${hook}.sh"
  
  if [ ! -f "$script" ]; then
    error "Hook script not found: $hook"
    exit 1
  fi
  
  info "Testing $hook hook..."
  bash "$script"
}

case "${1:-}" in
  list)
    list_profiles
    ;;
  use)
    switch_profile "$2"
    ;;
  current)
    current_profile
    ;;
  mute)
    mute
    ;;
  unmute)
    unmute
    ;;
  status)
    status
    ;;
  test)
    test_hook "$2"
    ;;
  -h|--help|help)
    usage
    ;;
  *)
    usage
    exit 1
    ;;
esac
