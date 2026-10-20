#!/bin/bash

FINDER_PLIST="$HOME/Library/Preferences/com.apple.finder.plist"

# ── Snap to Grid ─────────────────────────────────────────────
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" "$FINDER_PLIST" 2>/dev/null
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" "$FINDER_PLIST" 2>/dev/null

# Отступ от края (для правого Dock)
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 54" "$FINDER_PLIST" 2>/dev/null
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:viewOptionsVersion 1" "$FINDER_PLIST" 2>/dev/null

killall cfprefsd
killall Finder

echo "✔ Desktop: Snap to Grid enabled."
echo ""
echo "──────────────────────────────────────────────────────────"
echo "  📌 MANUAL STEP — Sort by Date Modified"
echo ""
echo "     macOS не позволяет включить 'Сетку' и 'Дату' одновременно"
echo "     через скрипт. Сделайте один раз вручную:"
echo ""
echo "       ПКМ по рабочему столу → Sort By → Date Modified"
echo ""
echo "     После этого иконки будут сортироваться по дате,"
echo "     а сетка останется включённой."
echo "──────────────────────────────────────────────────────────"