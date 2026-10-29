#!/bin/bash

ZSHRC="$HOME/.zshrc"

echo "→ Обновление конфигурации Zsh ($ZSHRC)..."

# Создаем файл, если его вдруг нет
touch "$ZSHRC"

# ── 1. Настройка Docker ──────────────────────────────────────
if ! grep -q "DOCKER_DEFAULT_PLATFORM" "$ZSHRC"; then
    echo "" >> "$ZSHRC"
    echo "# Docker default platform" >> "$ZSHRC"
    echo "export DOCKER_DEFAULT_PLATFORM='linux/amd64'" >> "$ZSHRC"
    echo "  ✔ Добавлен DOCKER_DEFAULT_PLATFORM"
else
    echo "  ⏭  DOCKER_DEFAULT_PLATFORM уже настроен."
fi

# ── 2. Фикс ошибки GPG ───────────────────────────────────────
if ! grep -q "GPG_TTY" "$ZSHRC"; then
    echo "" >> "$ZSHRC"
    echo "# For GPG error: no file /.gnupg/pubring.gpg fix" >> "$ZSHRC"
    echo "export GPG_TTY=\$(tty)" >> "$ZSHRC"
    echo "  ✔ Добавлен GPG_TTY"
else
    echo "  ⏭  GPG_TTY уже настроен."
fi

# ── 3. Алиас для VPN ─────────────────────────────────────────
if ! grep -q "alias vpn=" "$ZSHRC"; then
    echo "" >> "$ZSHRC"
    echo "# VPN via sshuttle" >> "$ZSHRC"
    echo "alias vpn='sudo sshuttle -r root@45.12.68.191 0/0 --dns'" >> "$ZSHRC"
    echo "  ✔ Добавлен алиас 'vpn'"
else
    echo "  ⏭  Алиас 'vpn' уже существует."
fi

echo "✔ Конфигурация Zsh обновлена."

