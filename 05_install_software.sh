#!/bin/bash

# ══════════════════════════════════════════════════════════════
# Универсальный установщик приложений и утилит
# Формат: "Тип|Имя_в_brew|Путь_для_проверки|Описание"
# ══════════════════════════════════════════════════════════════
APPS=(
    # Консольные утилиты
    "formula|git|/usr/bin/git|Git"
    "formula|protobuf|/opt/homebrew/bin/protoc|Google Protobuf"  # <── Правильный формат
    "formula|pkg-config|/opt/homebrew/bin/pkg-config|pkg-config"  # <── Добавлена эта строка

    # Обычные GUI-приложения
    "cask|karabiner-elements|/Applications/Karabiner-Elements.app|Karabiner-Elements"
    "cask|telegram|/Applications/Telegram.app|Telegram"
    "cask|dbeaver-community|/Applications/DBeaver.app|DBeaver Community"
    "cask|opera-gx|/Applications/Opera GX.app|Opera GX"
    "cask|docker-desktop|/Applications/Docker.app|Docker Desktop"
    "cask|codex|/opt/homebrew/bin/codex|Codex CLI"
    "cask|maccy|/Applications/Maccy.app|Maccy (менеджер буфера)"
    "cask|jordanbaird-ice|/Applications/Ice.app|Ice (меню-бар)"

    # GoLand EAP
    "cask|goland-eap|/Applications/GoLand.app|GoLand EAP"
)

for entry in "${APPS[@]}"; do
    IFS='|' read -r type app_name app_path app_desc <<< "$entry"

    if [ -e "$app_path" ]; then
        echo "✔ Already installed: $app_desc"
    else
        echo "Installing: $app_desc ..."

        # Специальная подготовка
        if [ "$app_name" = "goland-eap" ]; then
            brew tap dahlia/jetbrains-eap
            brew trust --cask dahlia/jetbrains-eap/goland-eap
        fi

        # Выполняем установку
        if [ "$type" = "cask" ]; then
            brew install --cask "$app_name"
        else
            brew install "$app_name"
        fi

        if [ $? -eq 0 ]; then
            echo "✔ Installed: $app_desc"

            # ── Пост-установочные действия для Karabiner ──
            if [ "$app_name" = "karabiner-elements" ]; then
                echo "  Creating Karabiner rule for Terminal..."
                KARABINER_ASSETS_DIR="$HOME/.config/karabiner/assets/complex_modifications"
                mkdir -p "$KARABINER_ASSETS_DIR"

                RULE_JSON=$(cat <<'EOF'
{
  "title": "Open Terminal with Cmd+Opt+T",
  "rules": [
    {
      "description": "Open Terminal",
      "manipulators": [
        {
          "type": "basic",
          "from": {
            "key_code": "t",
            "modifiers": {
              "mandatory": ["command", "option"]
            }
          },
          "to": [
            {
              "shell_command": "open -a Terminal"
            }
          ]
        }
      ]
    }
  ]
}
EOF
)
                echo "$RULE_JSON" > "$KARABINER_ASSETS_DIR/open_terminal.json"
                echo "  ✔ Rule created: $KARABINER_ASSETS_DIR/open_terminal.json"
            fi
            # ──────────────────────────────────────────────

        else
            echo "❌ Failed: $app_desc"
        fi
    fi
done

echo ""
echo "══════════════════════════════════════════"
echo "  ⚠️  ВАЖНО: Настройка Karabiner-Elements"
echo "══════════════════════════════════════════"
echo "  Karabiner требует разрешений для работы."
echo "  1. Откройте Karabiner-Elements."
echo "  2. Выдайте разрешения в System Settings:"
echo "     - Privacy & Security → Accessibility"
echo "     - Privacy & Security → Input Monitoring"
echo "  3. Разрешите расширение драйвера:"
echo "     System Settings → General → Login Items & Extensions"
echo "     → Driver Extensions."
echo "  4. В приложении перейдите в Complex Modifications,"
echo "     нажмите 'Add rule' и активируйте 'Open Terminal'."
echo "  5. Перезагрузите Mac."
echo "══════════════════════════════════════════"