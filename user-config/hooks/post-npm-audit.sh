#!/bin/bash
# PostToolUse hook: npm install után automatikus audit figyelmeztetés
INPUT=$(cat)
CMD=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('tool_input',{}).get('command',''))
except: print('')
" 2>/dev/null)

if echo "$CMD" | grep -qE "npm install|npm i |npx "; then
    echo '{"hookSpecificOutput":{"additionalContext":"⚠️ npm install detektálva! Futtasd: npm audit. Supply chain támadás megelőzés: ellenőrizd a package-lock.json változásokat és új dependency-ket."}}'
else
    echo '{}'
fi
