#!/bin/bash

# Экспортируем путь к Homebrew для ВСЕХ дочерних скриптов
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"

SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_FILE="$SCRIPTS_DIR/setup_log.txt"

STEPS=(
    "01_settings.sh"
    "02_homebrew.sh"
    "03_dock.sh"
    "04_desktop.sh"
    "05_install_software.sh"
    "06_reminders.sh"
    "07_shell_config.sh"
    "08_goland_config.sh"
    "09_ssh_key.sh"
)

# Очищаем старый лог-файл перед новым запуском (или создаем новый)
> "$LOG_FILE"

# Весь основной блок оборачиваем в {}, а вывод дублируем в tee
{
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
    echo ""
    echo "📄 Лог сохранен в: $LOG_FILE"
} 2>&1 | tee "$LOG_FILE"