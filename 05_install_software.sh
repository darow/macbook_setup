#!/bin/bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

require_brew

# ══════════════════════════════════════════════════════════════
# Универсальный установщик приложений и утилит
# Формат: "Тип|Имя_в_brew|Путь_для_проверки|Описание"
# ══════════════════════════════════════════════════════════════
APPS=(
    # Консольные утилиты
    "formula|sshuttle|/opt/homebrew/bin/sshuttle|sshuttle (VPN)"
    "formula|git|/usr/bin/git|Git"
    "formula|protobuf|/opt/homebrew/bin/protoc|Google Protobuf"
    "formula|pkg-config|/opt/homebrew/bin/pkg-config|pkg-config"
    "formula|helm|/opt/homebrew/bin/helm|Helm"
    "formula|duti|/opt/homebrew/bin/duti|duti (смена ассоциаций файлов)"

    # Обычные GUI-приложения
    "cask|karabiner-elements|/Applications/Karabiner-Elements.app|Karabiner-Elements"
    "cask|telegram|/Applications/Telegram.app|Telegram"
    "cask|dbeaver-community|/Applications/DBeaver.app|DBeaver Community"
    "cask|goland-eap|/Applications/GoLand.app|GoLand EAP"
    "cask|opera-gx|/Applications/Opera GX.app|Opera GX"
    "cask|docker-desktop|/Applications/Docker.app|Docker Desktop"
    "cask|codex|/opt/homebrew/bin/codex|Codex CLI"
    "cask|maccy|/Applications/Maccy.app|Maccy (менеджер буфера)"
    "cask|jordanbaird-ice|/Applications/Ice.app|Ice (меню-бар)"
    "cask|postman|/Applications/Postman.app|Postman"
    "cask|cursor-cli|/opt/homebrew/bin/agent|Cursor CLI"
)

KARABINER_RULE_SRC="$REPO_ROOT/assets/karabiner/open_terminal.json"

for entry in "${APPS[@]}"; do
    IFS='|' read -r type app_name app_path app_desc <<< "$entry"

    if [ -e "$app_path" ]; then
        log_ok "Already installed: $app_desc"
    else
        echo "Installing: $app_desc ..."

        # Специальная подготовка
        if [ "$app_name" = "goland-eap" ]; then
            brew tap dahlia/jetbrains-eap
            brew trust --cask dahlia/jetbrains-eap/goland-eap
        fi

        # Выполняем установку
        if [ "$type" = "cask" ]; then
            install_ok=true
            brew install --cask "$app_name" || install_ok=false
        else
            install_ok=true
            brew install "$app_name" || install_ok=false
        fi

        if [ "$install_ok" = true ]; then
            log_ok "Installed: $app_desc"

            # ── Пост-установочные действия для Karabiner ──
            if [ "$app_name" = "karabiner-elements" ]; then
                echo "  Creating Karabiner rule for Terminal..."
                KARABINER_ASSETS_DIR="$HOME/.config/karabiner/assets/complex_modifications"
                mkdir -p "$KARABINER_ASSETS_DIR"
                cp "$KARABINER_RULE_SRC" "$KARABINER_ASSETS_DIR/open_terminal.json"
                echo "  ✔ Rule created: $KARABINER_ASSETS_DIR/open_terminal.json"
            fi
        else
            log_err "Failed: $app_desc"
        fi
    fi
done

# ══════════════════════════════════════════════════════════════
# Настройка приложений по умолчанию
# ══════════════════════════════════════════════════════════════
echo ""
log_info "Настройка приложений по умолчанию..."

if command -v duti >/dev/null 2>&1; then
    # Назначаем TextEdit приложением по умолчанию для .sh скриптов
    duti -s com.apple.TextEdit .sh all
    echo "  ✔ TextEdit назначен для .sh файлов."

    # Принудительно обновляем базу LaunchServices, чтобы Finder сразу подхватил изменения
    /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user >/dev/null 2>&1 || true
else
    echo "  ⚠️  duti не найден. Пропускаем настройку .sh."
fi
