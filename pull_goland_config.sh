#!/bin/bash

# Папка, куда сохраняем конфиг для Git
BACKUP_DIR="$(cd "$(dirname "$0")" && pwd)/goland_backup"
mkdir -p "$BACKUP_DIR"

# Ищем самую свежую версию GoLand (сортировка по имени, берем последнюю)
GOLAND_DIR=$(find "$HOME/Library/Application Support/JetBrains" -maxdepth 1 -type d -name "GoLand*" | sort -V | tail -n 1)

if [ -z "$GOLAND_DIR" ] || [ ! -d "$GOLAND_DIR" ]; then
    echo "❌ Папка настроек GoLand не найдена. Вы запускали GoLand?"
    exit 1
fi

echo "→ Найдена папка настроек: $(basename "$GOLAND_DIR")"

# Копируем файл темы
if [ -f "$GOLAND_DIR/options/laf.xml" ]; then
    cp "$GOLAND_DIR/options/laf.xml" "$BACKUP_DIR/"
    echo "✔ Скопирован файл темы (laf.xml)"
else
    echo "⚠️  Файл laf.xml не найден в $GOLAND_DIR/options/"
fi

# Сюда можно добавить копирование других файлов, если нужно:
# cp "$GOLAND_DIR/options/editor-font.xml" "$BACKUP_DIR/" 2>/dev/null
# cp "$GOLAND_DIR/options/keymap.xml" "$BACKUP_DIR/" 2>/dev/null

echo "✔ Настройки сохранены в папку: $BACKUP_DIR"
echo "  Теперь сделай git add, commit и push."