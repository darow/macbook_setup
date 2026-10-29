#!/bin/bash

FINDER_PLIST="$HOME/Library/Preferences/com.apple.finder.plist"

# Получаем текущее значение arrangeBy. Если ключа нет, вернется пустая строка.
CURRENT_ARRANGE=$(/usr/libexec/PlistBuddy -c "Print :DesktopViewSettings:IconViewSettings:arrangeBy" "$FINDER_PLIST" 2>/dev/null)

# Проверяем, установлена ли уже сортировка по дате
if [[ "$CURRENT_ARRANGE" == *"date"* ]]; then
    echo "✔ Настройки рабочего стола уже кастомизированы (сортировка по дате: $CURRENT_ARRANGE)."
    echo "  Пропускаем изменение."
else
    echo "→ Настраиваем рабочий стол (включаем сетку и сортировку по дате изменения)..."
    
    # Устанавливаем сортировку по дате изменения
    /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy dateModified" "$FINDER_PLIST" 2>/dev/null
    
    # Настраиваем отступы и версию (чтобы Finder не сбрасывал сетку под Dock)
    /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 54" "$FINDER_PLIST" 2>/dev/null
    /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:viewOptionsVersion 1" "$FINDER_PLIST" 2>/dev/null
    
    killall cfprefsd
    killall Finder
    echo "✔ Сортировка по дате изменения применена."
fi