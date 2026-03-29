#!/bin/bash
# HMI Local AI — Claude Code + Remote Control (egy terminálban)

SESSION="Local AI $(date +%Y%m%d)"

echo ""
echo "  ╔══════════════════════════════════════╗"
echo "  ║  HMI Local AI Dev Session            ║"
echo "  ║  Session: $SESSION            ║"
echo "  ╚══════════════════════════════════════╝"
echo ""

# Remote Control háttérben (mobil hozzáférés)
claude remote-control --name "$SESSION" > /tmp/hmi-remote.log 2>&1 &
REMOTE_PID=$!
echo "  Remote Control: PID $REMOTE_PID (háttér)"
echo "  Mobil: Claude app → automatikusan megtalálja"
echo ""

# Claude Code interaktívan (előtér)
claude --dangerously-skip-permissions -n "$SESSION"

# Kilépéskor remote control leállítása
kill $REMOTE_PID 2>/dev/null
