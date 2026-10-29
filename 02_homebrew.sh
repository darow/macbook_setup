#!/bin/bash

# ── 1. Установка Homebrew (если нет) ─────────────────────────
if command -v brew >/dev/null 2>&1; then
    echo "✔ Homebrew already installed."
else
    echo "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# ── 2. Добавление в PATH для ВСЕХ будущих сессий ─────────────
# Это делает настройку постоянной, а не только для текущего скрипта
if ! grep -q "brew shellenv" "$HOME/.zprofile" 2>/dev/null; then
    echo "→ Добавление Homebrew в $HOME/.zprofile..."
    echo "" >> "$HOME/.zprofile"
    echo "# Homebrew" >> "$HOME/.zprofile"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
    echo "  ✔ Настройка сохранена."
else
    echo "✔ Homebrew уже настроен в .zprofile."
fi

# ── 3. Активация для ТЕКУЩЕГО скрипта (чтобы 03 и 05 сработали) ──
if [ -x "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ── 4. Проверка ──────────────────────────────────────────────
if command -v brew >/dev/null 2>&1; then
    echo "✔ Homebrew ready: $(brew --version | head -n1)"
else
    echo "❌ КРИТИЧЕСКАЯ ОШИБКА: Homebrew не установлен."
    exit 1
fi