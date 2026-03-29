#!/bin/bash
# PostToolUse hook: git commit után emlékeztető a DAILY_LOG frissítésre
INPUT=$(cat)
CMD=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('tool_input',{}).get('command',''))
except: print('')
" 2>/dev/null)

if echo "$CMD" | grep -q "git commit"; then
    echo '{"hookSpecificOutput":{"additionalContext":"EMLÉKEZTETŐ: Frissítsd az alapadatok/DAILY_LOG.md fájlt az elvégzett munkával!"}}'
else
    echo '{}'
fi
