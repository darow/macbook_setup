#!/bin/bash

# ── Настройки комментария ключа ──────────────────────────────
# Автоматически берем имя пользователя из системы
CURRENT_USER=$(whoami)
# Используем экранирование \{ \}, чтобы скобки были частью текста
KEY_COMMENT="\{${CURRENT_USER}\}-\{gitlab\}"

# ── Генерация SSH-ключа ──────────────────────────────────────
echo "→ Проверка SSH-ключа..."

if [ -f "$HOME/.ssh/id_ed25519" ]; then
    echo "⚠️  SSH-ключ уже существует: $HOME/.ssh/id_ed25519"
    echo "   Если вы хотите перегенерировать его, удалите файлы:"
    echo "   rm ~/.ssh/id_ed25519*"
else
    echo "→ Генерация нового SSH-ключа (Ed25519) с комментарием: $KEY_COMMENT"
    
    ssh-keygen -t ed25519 -C "$KEY_COMMENT" -f "$HOME/.ssh/id_ed25519" -N ""
    
    if [ $? -eq 0 ]; then
        echo "✔ Ключ успешно сгенерирован."
    else
        echo "❌ Ошибка при генерации ключа."
        exit 1
    fi
fi

# ── Добавление ключа в ssh-agent и Keychain macOS ────────────
echo "→ Добавление ключа в ssh-agent (macOS Keychain)..."
eval "$(ssh-agent -s)" >/dev/null 2>&1
ssh-add --apple-use-keychain "$HOME/.ssh/id_ed25519" >/dev/null 2>&1
echo "✔ Ключ добавлен в ssh-agent."

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