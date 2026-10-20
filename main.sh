#!/bin/bash

SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"

STEPS=(
    "01_scrolling.sh"
    "02_homebrew.sh"
    "03_dock.sh"
    "04_desktop.sh"
    "05_install_software.sh"
    "06_reminders.sh"
)

for step in "${STEPS[@]}"; do
    SCRIPT="$SCRIPTS_DIR/$step"
    if [ -f "$SCRIPT" ]; then
        echo ""
        echo "══════════════════════════════════════════"
        echo "  Running: $step"
        echo "══════════════════════════════════════════"
        bash "$SCRIPT"
    else
        echo "⚠️  Missing: $step"
    fi
done

echo ""
echo "══════════════════════════════════════════"
echo "  ✔ All steps complete."
echo "══════════════════════════════════════════"