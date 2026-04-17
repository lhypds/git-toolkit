#!/bin/bash

# Launcher for list_weekly_prs.sh
# Double-click this file on macOS to run the script in Terminal.

REPO="linktivity/ars-neo-miniapp"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
bash "$SCRIPT_DIR/list_weekly_prs.sh" --repo="$REPO" "$@"
