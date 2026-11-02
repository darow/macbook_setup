#!/bin/bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

# Папка, куда сохраняем конфиг для Git
BACKUP_DIR="$REPO_ROOT/goland_backup"
mkdir -p "$BACKUP_DIR"

# Ищем самую свежую версию GoLand (сортировка по имени, берем последнюю)
GOLAND_DIR=$(find_goland_dir)

if [ -z "$GOLAND_DIR" ] || [ ! -d "$GOLAND_DIR" ]; then
    log_err "Папка настроек GoLand не найдена. Вы запускали GoLand?"
    exit 1
fi

log_info "Найдена папка настроек: $(basename "$GOLAND_DIR")"

# Копируем файл темы
if [ -f "$GOLAND_DIR/options/laf.xml" ]; then
    cp "$GOLAND_DIR/options/laf.xml" "$BACKUP_DIR/"
    log_ok "Скопирован файл темы (laf.xml)"
else
    log_warn "Файл laf.xml не найден в $GOLAND_DIR/options/"
fi

log_ok "Настройки сохранены в папку: $BACKUP_DIR"
echo "  Теперь сделай git add, commit и push."
