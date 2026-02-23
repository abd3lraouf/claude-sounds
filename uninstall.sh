#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR"

source "$REPO_DIR/lib/common.sh"
source "$REPO_DIR/lib/settings.sh"

usage() {
  echo "Usage: $0 [OPTIONS]"
  echo ""
  echo "Uninstall Claude Code sound effects."
  echo ""
  echo "Options:"
  echo "  -p, --profile NAME   Profile to uninstall (default: all)"
  echo "  -k, --keep-sounds    Keep sound files, only remove hooks"
  echo "  -h, --help           Show this help message"
}

uninstall() {
  local profile="$1"
  local keep_sounds="$2"
  local claude_dir=$(get_claude_dir)
  
  local profiles_dir="$claude_dir/profiles"
  local scripts_dir="$claude_dir/scripts"
  local settings_file="$claude_dir/settings.json"
  
  info "Uninstalling Claude Code sound effects..."
  
  if [ -n "$profile" ]; then
    info "Removing profile: $profile"
    
    if [ -d "$profiles_dir/$profile" ] && [ "$keep_sounds" != "true" ]; then
      rm -rf "$profiles_dir/$profile"
      success "Removed sound files"
    fi
    
    rm -f "$scripts_dir/${profile}_session.sh" \
          "$scripts_dir/${profile}_prompt.sh" \
          "$scripts_dir/${profile}_stop.sh" \
          "$scripts_dir/${profile}_compact.sh"
    success "Removed hook scripts"
    
    if [ -f "$settings_file" ]; then
      info "Removing hooks from settings.json..."
      if remove_hooks "$settings_file" "$profile"; then
        success "Hooks removed"
      fi
    fi
    
    if [ -f "$claude_dir/.current_profile" ]; then
      local current=$(cat "$claude_dir/.current_profile")
      if [ "$current" = "$profile" ]; then
        rm -f "$claude_dir/.current_profile"
      fi
    fi
  else
    if [ -d "$profiles_dir" ] && [ "$keep_sounds" != "true" ]; then
      rm -rf "$profiles_dir"
      success "Removed all profiles"
    fi
    
    if [ -d "$scripts_dir" ]; then
      rm -f "$scripts_dir"/*_session.sh \
            "$scripts_dir"/*_prompt.sh \
            "$scripts_dir"/*_stop.sh \
            "$scripts_dir"/*_compact.sh \
            "$scripts_dir/profile-manager.sh"
      success "Removed all hook scripts"
    fi
    
    if [ -f "$settings_file" ]; then
      info "Removing all hooks from settings.json..."
      python3 -c "
import json
with open('$settings_file', 'r') as f:
    data = json.load(f)
if 'hooks' in data:
    del data['hooks']
with open('$settings_file', 'w') as f:
    json.dump(data, f, indent=2)
" 2>/dev/null || true
      success "All hooks removed"
    fi
    
    rm -f "$claude_dir/.current_profile"
    rm -f "$claude_dir/.state_"*
  fi
  
  echo ""
  success "Uninstall complete!"
}

main() {
  local profile=""
  local keep_sounds="false"
  
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -p|--profile)
        profile="$2"
        shift 2
        ;;
      -k|--keep-sounds)
        keep_sounds="true"
        shift
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
  
  uninstall "$profile" "$keep_sounds"
}

main "$@"
