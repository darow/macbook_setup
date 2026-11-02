#!/bin/bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

# ── 1. Установка Homebrew (если нет) ─────────────────────────
if command -v brew >/dev/null 2>&1; then
    log_ok "Homebrew already installed."
else
    echo "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# ── 2. Добавление в PATH для ВСЕХ будущих сессий ─────────────
if ensure_line_in_file "$HOME/.zprofile" "brew shellenv" \
    "# Homebrew" \
    'eval "$(/opt/homebrew/bin/brew shellenv)"'; then
    log_ok "Homebrew добавлен в $HOME/.zprofile."
else
    log_ok "Homebrew уже настроен в .zprofile."
fi

# ── 3. Активация для ТЕКУЩЕГО скрипта (чтобы 03 и 05 сработали) ──
require_brew

# ── 4. Проверка ──────────────────────────────────────────────
log_ok "Homebrew ready: $(brew --version | head -n1)"
