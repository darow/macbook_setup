#!/bin/bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

# Персональный CLI-хелпер: один бинарник в PATH с подкомандами, как таргеты в makefile.
# Документация: README.md, раздел «CLI-хелпер c».

BIN_DIR="$HOME/.local/bin"
BIN_PATH="$BIN_DIR/c"

log_info "Установка CLI-хелпера 'c' → $BIN_PATH"

mkdir -p "$BIN_DIR"
cat > "$BIN_PATH" << 'EOF'
#!/bin/bash
# Персональный CLI-хелпер (ставится скриптом macbook_setup/10_cmds.sh).

set -euo pipefail

cmd="${1:-help}"

case "$cmd" in
    help)
        cat << 'HELP'
Usage: c <command>

Commands:
  help   показать этот список
  tlog   логин в Teleport: tsh17 login --proxy=tp.rwb.ru --user=haleckiy.a2
  pods   поды notifier: kubectl -n notifier get pods -o wide
HELP
        ;;
    tlog)
        shift
        exec tsh17 login --proxy=tp.rwb.ru --user=haleckiy.a2 "$@"
        ;;
    pods)
        shift
        exec kubectl -n notifier get pods -o wide "$@"
        ;;
    *)
        echo "Неизвестная команда: $cmd" >&2
        echo "Список команд: c help" >&2
        exit 1
        ;;
esac
EOF
chmod +x "$BIN_PATH"
echo "  ✔ Установлен $BIN_PATH"

# PATH для ~/.local/bin в zsh
if ensure_line_in_file "$HOME/.zshrc" ".local/bin" \
    "# c (персональный CLI-хелпер)" \
    'export PATH="$HOME/.local/bin:$PATH"'; then
    echo "  ✔ ~/.local/bin добавлен в PATH (~/.zshrc)"
else
    echo "  ⏭  PATH уже настроен."
fi

log_ok "Готово. Откройте новый терминал (или: source ~/.zshrc) и попробуйте: c help"
