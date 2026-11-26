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

VAULT_ADDR="https://vault.wildberries.ru"

cmd="${1:-help}"

case "$cmd" in
    help)
        cat << 'HELP'
Usage: c <command>

Commands:
  help     показать этот список
  tlog     логин в Teleport: tsh17 login --proxy=tp.rwb.ru --user=haleckiy.a2

  kpods    поды notifier: kubectl -n notifier get pods -o wide
  klogs    логи сервиса notifier: c klogs <svc> [n] — с n: последние n строк, без n: следить (-f, все реплики)
  krestart рестарт деплоя в notifier: c krestart <svc> (rollout restart + status)
  klogin   kube login в stage-кластер: tsh17 kube login k8s.tns-stage-el
  kfw      port-forward PG stage: localhost:5432 → sender-router (мастер, Ctrl+C чтобы остановить)

  vget     секрет из Vault: c vget <path> [field] — без field: список ключей; с field: значение
  vren     продлить токен Vault (renew-self)
  vtok     обновить токен Vault: c vtok [<token>] — без аргумента берёт из буфера обмена, проверяет и сохраняет
HELP
        ;;
    tlog)
        shift
        exec tsh17 login --proxy=tp.rwb.ru --user=haleckiy.a2 "$@"
        ;;
    klogin)
        shift
        exec tsh17 kube login k8s.tns-stage-el "$@"
        ;;
    kpods)
        shift
        exec kubectl -n notifier get pods -o wide "$@"
        ;;
    kfw)
        shift
        exec kubectl -n sender port-forward svc/sender-router-pgsql-cl1-stage-haproxy 5432:5000 "$@"
        ;;
    klogs)
        shift
        svc="${1:?Использование: c klogs <svc> [n]}"
        if [ $# -ge 2 ]; then
            exec kubectl -n notifier logs --tail="$2" -l "app.kubernetes.io/instance=$svc" --prefix "$@"
        else
            exec kubectl -n notifier logs --tail=100 -f -l "app.kubernetes.io/instance=$svc" --prefix
        fi
        ;;
    krestart)
        shift
        svc="${1:?Использование: c krestart <svc>}"
        kubectl -n notifier rollout restart "deployment/$svc"
        exec kubectl -n notifier rollout status "deployment/$svc"
        ;;
    vget)
        shift
        path="${1:?Использование: c vget <vault/path> [field]}"
        field="${2:-}"
        [ -f "$HOME/.vault-token" ] || { echo "Нет $HOME/.vault-token — положи туда Vault-токен" >&2; exit 1; }
        tok="$(cat "$HOME/.vault-token")"
        resp="$(curl -sf --max-time 10 -H "X-Vault-Token: $tok" "$VAULT_ADDR/v1/$path")" \
            || { echo "Vault: запрос не удался ($path)" >&2; exit 1; }
        if [ -n "$field" ]; then
            val="$(printf '%s' "$resp" | jq -r --arg f "$field" '.data[$f] // empty')"
            [ -n "$val" ] || { echo "Поле '$field' не найдено в $path" >&2; exit 1; }
            printf '%s\n' "$val"
        else
            printf '%s' "$resp" | jq -r '.data | keys[]'
        fi
        ;;
    vren)
        shift
        [ -f "$HOME/.vault-token" ] || { echo "Нет $HOME/.vault-token — положи туда Vault-токен" >&2; exit 1; }
        tok="$(cat "$HOME/.vault-token")"
        curl -sf --max-time 10 -X POST -H "X-Vault-Token: $tok" "$VAULT_ADDR/v1/auth/token/renew-self" \
            | jq -r '"Токен продлён, ttl=" + (.auth.lease_duration|tostring) + "c"'
        ;;
    vtok)
        shift
        newtok="${1:-}"
        [ -z "$newtok" ] && newtok="$(pbpaste 2>/dev/null || true)"
        newtok="$(printf '%s' "$newtok" | tr -d '[:space:]')"
        if [ -z "$newtok" ]; then
            echo "Использование: c vtok [<token>]" >&2
            echo "Без аргумента берёт токен из буфера обмена (pbpaste)." >&2
            exit 1
        fi
        resp="$(curl -sf --max-time 10 -H "X-Vault-Token: $newtok" "$VAULT_ADDR/v1/auth/token/lookup")" \
            || { echo "❌ Токен невалиден (lookup failed) — НЕ сохранён" >&2; exit 1; }
        printf '%s' "$newtok" > "$HOME/.vault-token"
        chmod 600 "$HOME/.vault-token"
        echo "✔ Токен сохранён в ~/.vault-token, ttl=$(printf '%s' "$resp" | jq -r '.data.ttl')с, policies: $(printf '%s' "$resp" | jq -r '.data.policies | join(",")')"
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

# ── Системный cron: ежечасное продление Vault-токена ─────────
# Аналог crontab-строки: 0 * * * * ~/.local/bin/c vren >> ~/.vault-renew.log 2>&1
if crontab -l 2>/dev/null | grep -qF "c vren"; then
    echo "  ⏭  Cron продления Vault-токена уже настроен."
else
    (crontab -l 2>/dev/null; echo "0 * * * * $BIN_PATH vren >> $HOME/.vault-renew.log 2>&1") | crontab -
    echo "  ✔ Добавлен cron: ежечасно продлевает Vault-токен (лог: ~/.vault-renew.log)"
fi

log_ok "Готово. Откройте новый терминал (или: source ~/.zshrc) и попробуйте: c help"
