#!/bin/bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

ZSHRC="$HOME/.zshrc"

log_info "Обновление конфигурации Zsh ($ZSHRC)..."

# ── 1. Настройка Docker ──────────────────────────────────────
if ensure_line_in_file "$ZSHRC" "DOCKER_DEFAULT_PLATFORM" \
    "# Docker default platform" \
    "export DOCKER_DEFAULT_PLATFORM='linux/amd64'"; then
    echo "  ✔ Добавлен DOCKER_DEFAULT_PLATFORM"
else
    echo "  ⏭  DOCKER_DEFAULT_PLATFORM уже настроен."
fi

# ── 2. Фикс ошибки GPG ───────────────────────────────────────
if ensure_line_in_file "$ZSHRC" "GPG_TTY" \
    "# For GPG error: no file /.gnupg/pubring.gpg fix" \
    'export GPG_TTY=$(tty)'; then
    echo "  ✔ Добавлен GPG_TTY"
else
    echo "  ⏭  GPG_TTY уже настроен."
fi

# ── 3. Алиас для VPN ─────────────────────────────────────────
if ensure_line_in_file "$ZSHRC" "alias vpn=" \
    "# VPN via sshuttle" \
    "alias vpn='sudo sshuttle -r root@45.12.68.191 0/0 --dns'"; then
    echo "  ✔ Добавлен алиас 'vpn'"
else
    echo "  ⏭  Алиас 'vpn' уже существует."
fi

log_ok "Конфигурация Zsh обновлена."
