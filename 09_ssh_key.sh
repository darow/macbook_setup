#!/bin/bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

# ── Настройки комментария ключа ──────────────────────────────
CURRENT_USER=$(whoami)
KEY_COMMENT="{${CURRENT_USER}}-{gitlab}"

# ── Генерация SSH-ключа ──────────────────────────────────────
log_info "Проверка SSH-ключа..."

if [ -f "$HOME/.ssh/id_ed25519" ]; then
    log_warn "SSH-ключ уже существует: $HOME/.ssh/id_ed25519"
    echo "   Если вы хотите перегенерировать его, удалите файлы:"
    echo "   rm ~/.ssh/id_ed25519*"
else
    log_info "Генерация нового SSH-ключа (Ed25519) с комментарием: $KEY_COMMENT"

    if ssh-keygen -t ed25519 -C "$KEY_COMMENT" -f "$HOME/.ssh/id_ed25519" -N ""; then
        log_ok "Ключ успешно сгенерирован."
    else
        log_err "Ошибка при генерации ключа."
        exit 1
    fi
fi

# ── Добавление ключа в ssh-agent и Keychain macOS ────────────
log_info "Добавление ключа в ssh-agent (macOS Keychain)..."
eval "$(ssh-agent -s)" >/dev/null 2>&1
ssh-add --apple-use-keychain "$HOME/.ssh/id_ed25519" >/dev/null 2>&1 || true
log_ok "Ключ добавлен в ssh-agent."

# ── Вывод публичного ключа для копирования ───────────────────
echo ""
echo "══════════════════════════════════════════════════════════"
echo "  📌 ВАШ ПУБЛИЧНЫЙ SSH-КЛЮЧ:"
echo "══════════════════════════════════════════════════════════"
echo ""
cat "$HOME/.ssh/id_ed25519.pub"
echo ""
echo "══════════════════════════════════════════════════════════"
echo "  ⚠️  СКОПИРУЙТЕ ЭТОТ КЛЮЧ И ДОБАВЬТЕ ЕГО В:"
echo "      1. GitHub:  https://github.com/settings/ssh/new"
echo "      2. GitLab:  https://gitlab.com/-/profile/keys"
echo ""
echo "  (Совет: используйте 'pbcopy' для копирования в буфер:)"
echo "    pbcopy < ~/.ssh/id_ed25519.pub"
echo "══════════════════════════════════════════════════════════"
