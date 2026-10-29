#!/bin/bash

# ── Включение Touch ID для sudo ──────────────────────────────
# Проверяем, включен ли уже Touch ID для sudo
if ! grep -q "pam_tid.so" /etc/pam.d/sudo_local 2>/dev/null; then
    echo "→ Включение Touch ID для sudo..."
    # Создаем файл из шаблона и добавляем строку
    sudo cp /etc/pam.d/sudo_local.template /etc/pam.d/sudo_local
    echo 'auth       sufficient     pam_tid.so' | sudo tee -a /etc/pam.d/sudo_local > /dev/null
    echo "  ✔ Touch ID для sudo включен."
else
    echo "✔ Touch ID для sudo уже настроен."
fi

# переключаем bashrc на zshrc
if [ "$SHELL" != "/bin/zsh" ]; then
    echo "→ Смена оболочки на Zsh..."
    chsh -s /bin/zsh
else
    echo "✔ Оболочка уже Zsh."
fi

# ── Отключить natural scrolling ──────────────────────────────
CURRENT=$(defaults read NSGlobalDomain com.apple.swipescrolldirection 2>/dev/null)

if [ "$CURRENT" = "0" ]; then
    echo "✔ Natural scrolling is already disabled."
else
    defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
    echo "✔ Natural scrolling disabled."
    echo "🔄 Restart or log out/in for it to take effect."
fi
echo ""

# ── F-клавиши без Fn ─────────────────────────────────────────
FN_STATE=$(defaults read NSGlobalDomain com.apple.keyboard.fnState 2>/dev/null)

if [ "$FN_STATE" = "1" ]; then
    echo "✔ F-keys already work without Fn."
else
    defaults write NSGlobalDomain com.apple.keyboard.fnState -bool true
    echo "✔ F-keys now work without Fn (use Fn+F1/F2 for brightness, etc.)."
fi
echo ""

# ── Отключить автозаглавные буквы ────────────────────────────
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
echo "✔ Automatic capitalization disabled."

# Применяем все изменения сразу
killall cfprefsd

defaults write com.apple.screencapture target clipboard
killall SystemUIServer