#!/bin/bash

# Позиция и внешний вид
defaults write com.apple.dock orientation -string "right"
defaults write com.apple.dock show-recents -bool false
killall Dock
sleep 1

echo "✔ Dock moved to the right, recent apps disabled."


# dockutil
if ! command -v dockutil >/dev/null 2>&1; then
    echo "Installing dockutil..."
    brew install dockutil
fi

if command -v dockutil >/dev/null 2>&1; then
    echo "✔ dockutil ready."
else
    echo "❌ dockutil install failed."
    exit 1
fi

# Очистка (если dockutil доступен)
if command -v dockutil >/dev/null 2>&1; then
    DOCK_APPS=$(dockutil --list | awk -F'\t' '{print $1}')

    for app in "Photos" "Calendar" "Music" "App Store" "Messages" "Mail" "Maps" "FaceTime" "Contacts" "Reminders" "TV" "Podcasts" "News" "Freeform"; do
        if echo "$DOCK_APPS" | grep -qx "$app"; then
            dockutil --remove "$app" --no-restart >/dev/null 2>&1
            echo "  ✔ Removed: $app"
        else
            echo "  ⏭  Skipped (not in Dock): $app"
        fi
    done

    killall Dock
    echo "✔ Dock cleaned up."
else
    echo "⚠️  dockutil not found. Skipping Dock cleanup."
fi