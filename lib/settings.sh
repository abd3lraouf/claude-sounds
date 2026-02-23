#!/bin/bash

source "${BASH_SOURCE[0]%/*}/common.sh"

merge_hooks() {
  local settings_file="$1"
  local profile="$2"
  local scripts_dir="$3"
  
  if [ ! -f "$settings_file" ]; then
    echo '{}' > "$settings_file"
  fi
  
  python3 << EOF
import json
import os
import re

settings_file = "$settings_file"
profile = "$profile"

with open(settings_file, 'r') as f:
    data = json.load(f)

new_hooks = {
  "SessionStart": [
    {
      "matcher": "startup|clear",
      "hooks": [
        {
          "type": "command",
          "command": "~/.claude/scripts/${profile}_session.sh"
        }
      ]
    }
  ],
  "UserPromptSubmit": [
    {
      "hooks": [
        {
          "type": "command",
          "command": "~/.claude/scripts/${profile}_prompt.sh"
        }
      ]
    }
  ],
  "Stop": [
    {
      "hooks": [
        {
          "type": "command",
          "command": "~/.claude/scripts/${profile}_stop.sh"
        }
      ]
    }
  ],
  "PreCompact": [
    {
      "hooks": [
        {
          "type": "command",
          "command": "~/.claude/scripts/${profile}_compact.sh"
        }
      ]
    }
  ]
}

def normalize_path(cmd):
    if cmd:
        home = os.path.expanduser('~')
        return cmd.replace(home, '~').replace('~/', '~/', 1)
    return cmd

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
                    new_cmd = new_item['hooks'][0].get('command') if new_item['hooks'] else None
                    new_cmd_norm = normalize_path(new_cmd)
                    
                    already_exists = False
                    for ex_item in existing:
                        if isinstance(ex_item, dict) and 'hooks' in ex_item:
                            for h in ex_item['hooks']:
                                if isinstance(h, dict) and 'command' in h:
                                    existing_cmd_norm = normalize_path(h.get('command'))
                                    if existing_cmd_norm == new_cmd_norm:
                                        already_exists = True
                                        break
                            if already_exists:
                                break
                    
                    if not already_exists:
                        existing.append(new_item)

with open(settings_file, 'w') as f:
    json.dump(data, f, indent=2)
EOF
  
  return $?
}

remove_hooks() {
  local settings_file="$1"
  local profile="$2"
  
  if [ ! -f "$settings_file" ]; then
    return 0
  fi
  
  python3 << EOF
import json
import re

settings_file = "$settings_file"
profile = "$profile"

with open(settings_file, 'r') as f:
    data = json.load(f)

if 'hooks' not in data:
    exit(0)

profile_pattern = re.compile(r'${profile}_(session|prompt|stop|compact)\.sh')

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

# Remove empty hook lists
for event in list(data['hooks'].keys()):
    if not data['hooks'][event]:
        del data['hooks'][event]

if not data['hooks']:
    del data['hooks']

with open(settings_file, 'w') as f:
    json.dump(data, f, indent=2)
EOF
  
  return $?
}
