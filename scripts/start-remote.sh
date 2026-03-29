#!/bin/bash
# HMI Local AI — Remote Control indítás
# Vár amíg a Claude Code session elindul, majd csatlakozik

SESSION="Local AI $(date +%Y%m%d)"

echo "Várakozás a Claude session-re (15 mp)..."
sleep 15

echo "Remote Control indítás: $SESSION"
claude remote-control --name "$SESSION"
