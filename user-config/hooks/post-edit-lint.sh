#!/bin/bash
# PostToolUse hook: Python fájlok automatikus ruff lint + fix
INPUT=$(cat)
FILE=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('tool_input',{}).get('file_path',''))
except: print('')
" 2>/dev/null)

if [[ "$FILE" == *.py ]] && [[ -f "$FILE" ]]; then
    cd "C:/Antigravity/HMI_Local_LLM" 2>/dev/null
    python -m ruff check --fix "$FILE" 2>/dev/null
fi
echo '{}'
