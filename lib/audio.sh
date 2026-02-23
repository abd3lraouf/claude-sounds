#!/bin/bash

source "${BASH_SOURCE[0]%/*}/common.sh"

detect_audio_player() {
  local os=$(detect_os)
  
  case "$os" in
    macos)
      if command_exists afplay; then
        echo "afplay"
        return 0
      elif command_exists ffplay; then
        echo "ffplay -nodisp -autoexit"
        return 0
      elif command_exists mpv; then
        echo "mpv --no-video --really-quiet"
        return 0
      fi
      ;;
    linux)
      if command_exists paplay; then
        echo "paplay"
        return 0
      elif command_exists aplay; then
        echo "aplay"
        return 0
      elif command_exists ffplay; then
        echo "ffplay -nodisp -autoexit"
        return 0
      elif command_exists mpv; then
        echo "mpv --no-video --really-quiet"
        return 0
      fi
      ;;
    wsl)
      if command_exists powershell.exe; then
        echo "wsl-powershell"
        return 0
      fi
      ;;
    windows)
      echo "powershell"
      return 0
      ;;
  esac
  
  return 1
}

get_play_command() {
  local player=$(detect_audio_player)
  
  case "$player" in
    "afplay")
      echo 'afplay "$SOUND_FILE" &'
      ;;
    "ffplay -nodisp -autoexit")
      echo 'ffplay -nodisp -autoexit "$SOUND_FILE" &>/dev/null &'
      ;;
    "mpv --no-video --really-quiet")
      echo 'mpv --no-video --really-quiet "$SOUND_FILE" &>/dev/null &'
      ;;
    "paplay")
      echo 'paplay "$SOUND_FILE" &'
      ;;
    "aplay")
      echo 'aplay "$SOUND_FILE" &>/dev/null &'
      ;;
    "wsl-powershell")
      echo 'powershell.exe -c "(New-Object Media.SoundPlayer \"\$(wslpath -w \"\$SOUND_FILE\")\").PlaySync()" &>/dev/null &'
      ;;
    "powershell")
      echo 'powershell -c "(New-Object Media.SoundPlayer \"\$SOUND_FILE\").PlaySync()" &'
      ;;
    *)
      return 1
      ;;
  esac
  
  return 0
}

check_audio_dependencies() {
  local os=$(detect_os)
  local player=$(detect_audio_player)
  
  if [ -z "$player" ]; then
    error "No audio player found!"
    echo ""
    echo "Please install one of the following:"
    case "$os" in
      macos)
        echo "  - afplay (built-in, should be available)"
        echo "  - ffmpeg: brew install ffmpeg"
        echo "  - mpv: brew install mpv"
        ;;
      linux)
        echo "  - pipewire-pulse: for paplay"
        echo "  - alsa-utils: for aplay"
        echo "  - ffmpeg: apt install ffmpeg"
        echo "  - mpv: apt install mpv"
        ;;
      wsl)
        echo "  - PowerShell (should be available via Windows interop)"
        ;;
    esac
    return 1
  fi
  
  success "Audio player detected: $player"
  return 0
}
