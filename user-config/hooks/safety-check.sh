#!/bin/bash
# HMI Safety Hook — veszélyes parancsok blokkolása
# PreToolUse hook a Bash tool-hoz

INPUT=$(cat)
CMD=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('command',''))" 2>/dev/null || echo "")

# Veszélyes minták
if echo "$CMD" | grep -qiE 'rm\s+-rf|DROP\s+TABLE|force-push|reset\s+--hard|git\s+clean\s+-f'; then
    echo '{"decision":"block","reason":"Veszélyes parancs blokkolva. Kérd a felhasználó jóváhagyását."}'
else
    echo '{"decision":"approve"}'
fi
