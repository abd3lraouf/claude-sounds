#!/bin/bash

PROFILE_NAME="__PROFILE__"
SOUNDS_DIR="__SOUNDS_DIR__"
STATE_FILE="$HOME/.claude/.state_${PROFILE_NAME}___HOOK__"
PLAY_CMD='__PLAY_CMD__'

SOUNDS=(
__SOUNDS__
)

play_sound() {
  local index="$1"
  local sound="${SOUNDS[$index]}"
  local sound_file="$SOUNDS_DIR/$sound"
  
  if [ -f "$sound_file" ]; then
    eval "$PLAY_CMD"
  fi
}

main() {
  local count=${#SOUNDS[@]}
  
  if [ $count -eq 0 ]; then
    exit 0
  fi
  
  local index=0
  if [ -f "$STATE_FILE" ]; then
    index=$(cat "$STATE_FILE")
  fi
  
  if [ "$index" -ge "$count" ] || [ "$index" -lt 0 ]; then
    index=0
  fi
  
  SOUND_FILE="$SOUNDS_DIR/${SOUNDS[$index]}"
  play_sound "$index"
  
  local next_index=$(( (index + 1) % count ))
  echo "$next_index" > "$STATE_FILE"
}

main "$@"
