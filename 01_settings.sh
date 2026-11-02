#!/bin/bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

# ── Включение Touch ID для sudo ──────────────────────────────
if ! grep -q "pam_tid.so" /etc/pam.d/sudo_local 2>/dev/null; then
    log_info "Включение Touch ID для sudo..."
    sudo cp /etc/pam.d/sudo_local.template /etc/pam.d/sudo_local
    echo 'auth       sufficient     pam_tid.so' | sudo tee -a /etc/pam.d/sudo_local > /dev/null
    log_ok "Touch ID для sudo включен."
else
    log_ok "Touch ID для sudo уже настроен."
fi

# переключаем bashrc на zshrc
if [ "$SHELL" != "/bin/zsh" ]; then
    log_info "Смена оболочки на Zsh..."
    chsh -s /bin/zsh
else
    log_ok "Оболочка уже Zsh."
fi

# ── Отключить natural scrolling ──────────────────────────────
CURRENT=$(defaults read NSGlobalDomain com.apple.swipescrolldirection 2>/dev/null || true)

if [ "$CURRENT" = "0" ]; then
    log_ok "Natural scrolling is already disabled."
else
    defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
    log_ok "Natural scrolling disabled."
    echo "🔄 Restart or log out/in for it to take effect."
fi
echo ""

# ── F-клавиши без Fn ─────────────────────────────────────────
FN_STATE=$(defaults read NSGlobalDomain com.apple.keyboard.fnState 2>/dev/null || true)

if [ "$FN_STATE" = "1" ]; then
    log_ok "F-keys already work without Fn."
else
    defaults write NSGlobalDomain com.apple.keyboard.fnState -bool true
    log_ok "F-keys now work without Fn (use Fn+F1/F2 for brightness, etc.)."
fi
echo ""

# ── Отключить автозаглавные буквы ────────────────────────────
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
log_ok "Automatic capitalization disabled."

# Применяем все изменения сразу
killall cfprefsd 2>/dev/null || true

defaults write com.apple.screencapture target clipboard
killall SystemUIServer 2>/dev/null || true
