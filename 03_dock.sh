#!/bin/bash

# ── 1. Настройка внешнего вида ───────────────────────────────
defaults write com.apple.dock orientation -string "right"
defaults write com.apple.dock show-recents -bool false
killall Dock
sleep 1

echo "✔ Dock moved to the right, recent apps disabled."
echo ""

# ── 2. Установка dockutil (если нет) ─────────────────────────
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
echo ""

# ── 3. Умная очистка ─────────────────────────────────────────
# Приложения, которые мы ОСТАВЛЯЕМ (имена как в dockutil --list)
KEEP_APPS=(
    "Терминал"
    "Terminal"
)

# Получаем список ВСЕХ приложений (persistentApps)
ALL_APPS=$(dockutil --list | awk -F'\t' '$3 == "persistentApps" {print $1}')

echo "→ Начинаем очистку Дока..."

while IFS= read -r app_name; do
    [ -z "$app_name" ] && continue

    REMOVE=true
    for keep in "${KEEP_APPS[@]}"; do
        if [ "$app_name" = "$keep" ]; then
            REMOVE=false
            break
        fi
    done

    if [ "$REMOVE" = true ]; then
        dockutil --remove "$app_name" --no-restart >/dev/null 2>&1
        echo "  ❌ Удалено: $app_name"
    else
        echo "  ✅ Оставлено: $app_name"
    fi
done <<< "$ALL_APPS"

# ── 4. Восстановление системных элементов ────────────────────
echo "→ Настройка папок и системных ярлыков..."

# Удаляем старые кривые папки, если они были добавлены скриптом ранее
dockutil --remove "Загрузки" --no-restart >/dev/null 2>&1
dockutil --remove "Downloads" --no-restart >/dev/null 2>&1
dockutil --remove "Приложения" --no-restart >/dev/null 2>&1
dockutil --remove "Applications" --no-restart >/dev/null 2>&1

# Добавляем системный Launchpad ("Приложения") на позицию 1 (сразу после Finder)
if [ -d "/System/Applications/Apps.app" ]; then
    dockutil --add "/System/Applications/Apps.app" --position 1 --no-restart >/dev/null 2>&1
    echo "  ✅ Добавлен Launchpad (Приложения)"
elif [ -d "/System/Applications/Launchpad.app" ]; then
    # Для старых версий macOS
    dockutil --add "/System/Applications/Launchpad.app" --position 1 --no-restart >/dev/null 2>&1
    echo "  ✅ Добавлен Launchpad"
fi


# Очищаем "Недавние места" (recentApps)
defaults write com.apple.dock recent-apps -array

killall Dock
echo ""
echo "✔ Dock cleaned up. Finder, Launchpad и Загрузки на месте."