#!/bin/bash

source "${BASH_SOURCE[0]%/*}/common.sh"

merge_hooks() {
  local settings_file="$1"
  local profile="$2"
  local scripts_dir="$3"
  
  local temp_file=$(mktemp)
  
  if [ ! -f "$settings_file" ]; then
    echo '{}' > "$settings_file"
  fi
  
  local existing_hooks=$(cat "$settings_file" | python3 -c '
import json, sys
data = json.load(sys.stdin)
hooks = data.get("hooks", {})
print(json.dumps(hooks))
' 2>/dev/null)
  
  if [ $? -ne 0 ]; then
    warn "Could not parse existing settings.json, creating new hooks section"
    existing_hooks="{}"
  fi
  
  local new_hooks=$(cat <<EOF
{
  "SessionStart": [
    {
      "matcher": "startup|clear",
      "hooks": [
        {
          "type": "command",
          "command": "$scripts_dir/${profile}_session.sh"
        }
      ]
    }
  ],
  "UserPromptSubmit": [
    {
      "hooks": [
        {
          "type": "command",
          "command": "$scripts_dir/${profile}_prompt.sh"
        }
      ]
    }
  ],
  "Stop": [
    {
      "hooks": [
        {
          "type": "command",
          "command": "$scripts_dir/${profile}_stop.sh"
        }
      ]
    }
  ],
  "PreCompact": [
    {
      "hooks": [
        {
          "type": "command",
          "command": "$scripts_dir/${profile}_compact.sh"
        }
      ]
    }
  ]
}
EOF
)
  
  python3 -c "
import json, sys

with open('$settings_file', 'r') as f:
    data = json.load(f)

new_hooks = $new_hooks

if 'hooks' not in data:
    data['hooks'] = {}

for event, hooks_list in new_hooks.items():
    if event not in data['hooks']:
        data['hooks'][event] = hooks_list
    else:
        existing = data['hooks'][event]
        if isinstance(existing, list):
            for new_item in hooks_list:
                if isinstance(new_item, dict) and 'hooks' in new_item:
                    cmd = new_item['hooks'][0]['command'] if new_item['hooks'] else None
                    exists = False
                    for ex_item in existing:
                        if isinstance(ex_item, dict) and 'hooks' in ex_item:
                            for h in ex_item['hooks']:
                                if h.get('command') == cmd:
                                    exists = True
                                    break
                    if not exists:
                        existing.append(new_item)

with open('$settings_file', 'w') as f:
    json.dump(data, f, indent=2)
" 2>/dev/null
  
  if [ $? -ne 0 ]; then
    rm -f "$temp_file"
    return 1
  fi
  
  rm -f "$temp_file"
  return 0
}

remove_hooks() {
  local settings_file="$1"
  local profile="$2"
  
  if [ ! -f "$settings_file" ]; then
    return 0
  fi
  
  python3 -c "
import json, re

with open('$settings_file', 'r') as f:
    data = json.load(f)

if 'hooks' not in data:
    exit(0)

profile_pattern = re.compile(r'${profile}_(session|prompt|stop|compact)\.sh$')

for event in list(data['hooks'].keys()):
    if isinstance(data['hooks'][event], list):
        new_hooks = []
        for item in data['hooks'][event]:
            if isinstance(item, dict) and 'hooks' in item:
                filtered = []
                for h in item['hooks']:
                    if isinstance(h, dict) and 'command' in h:
                        if not profile_pattern.search(h['command']):
                            filtered.append(h)
                    else:
                        filtered.append(h)
                if filtered:
                    item['hooks'] = filtered
                    new_hooks.append(item)
            else:
                new_hooks.append(item)
        data['hooks'][event] = new_hooks

if all(not v for v in data['hooks'].values()):
    del data['hooks']

with open('$settings_file', 'w') as f:
    json.dump(data, f, indent=2)
" 2>/dev/null
  
  return $?
}
