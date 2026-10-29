#!/bin/bash

# Путь к сохраненным настройкам в репозитории
SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)/goland_backup"

if [ ! -d "$SOURCE_DIR" ]; then
    echo "⚠️  Папка с настройками GoLand ($SOURCE_DIR) не найдена. Пропускаем шаг."
    exit 0
fi

# Ищем самую свежую версию GoLand на новом Mac
GOLAND_DIR=$(find "$HOME/Library/Application Support/JetBrains" -maxdepth 1 -type d -name "GoLand*" | sort -V | tail -n 1)

# Если папки нет (GoLand еще ни разу не запускали), берем версию из репозитория
if [ -z "$GOLAND_DIR" ]; then
    echo "→ Папка GoLand не найдена. Создаем папку для версии 2026.3..."
    GOLAND_DIR="$HOME/Library/Application Support/JetBrains/GoLand2026.3"
fi

echo "→ Применяем настройки в: $(basename "$GOLAND_DIR")"

# Создаем папку options, если ее нет
mkdir -p "$GOLAND_DIR/options"

# Копируем файл темы
if [ -f "$SOURCE_DIR/laf.xml" ]; then
    cp "$SOURCE_DIR/laf.xml" "$GOLAND_DIR/options/"
    echo "✔ Файл темы (laf.xml) успешно скопирован."
fi

# Копирование других файлов, если добавишь их в pull-скрипт
# cp "$SOURCE_DIR/editor-font.xml" "$GOLAND_DIR/options/" 2>/dev/null

echo "✔ Настройки GoLand применены."