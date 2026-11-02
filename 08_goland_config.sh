#!/bin/bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

# Путь к сохраненным настройкам в репозитории
SOURCE_DIR="$REPO_ROOT/goland_backup"

if [ ! -d "$SOURCE_DIR" ]; then
    log_warn "Папка с настройками GoLand ($SOURCE_DIR) не найдена. Пропускаем шаг."
    exit 0
fi

# Ищем самую свежую версию GoLand на новом Mac
GOLAND_DIR=$(find_goland_dir)

# Если папки нет (GoLand еще ни разу не запускали), берем версию из репозитория
if [ -z "$GOLAND_DIR" ]; then
    log_info "Папка GoLand не найдена. Создаем папку для версии 2026.3..."
    GOLAND_DIR="$HOME/Library/Application Support/JetBrains/GoLand2026.3"
fi

log_info "Применяем настройки в: $(basename "$GOLAND_DIR")"

# Создаем папку options, если ее нет
mkdir -p "$GOLAND_DIR/options"

# Копируем файл темы
if [ -f "$SOURCE_DIR/laf.xml" ]; then
    cp "$SOURCE_DIR/laf.xml" "$GOLAND_DIR/options/"
    log_ok "Файл темы (laf.xml) успешно скопирован."
fi

log_ok "Настройки GoLand применены."
