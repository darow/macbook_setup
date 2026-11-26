#!/bin/bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

# Персональный CLI-хелпер: один бинарник в PATH с подкомандами, как таргеты в makefile.
# Документация: README.md, раздел «CLI-хелпер f».

BIN_DIR="$HOME/.local/bin"
BIN_PATH="$BIN_DIR/f"

log_info "Установка CLI-хелпера 'f' → $BIN_PATH"

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
Usage: f <command>

Commands:
  help     показать этот список
  tlog     логин в Teleport: tsh17 login --proxy=tp.rwb.ru --user=haleckiy.a2

  kpods    поды notifier: kubectl -n notifier get pods -o wide
  klogs    логи сервиса notifier: f klogs <svc> [n] — с n: последние n строк, без n: следить (-f, все реплики)
  krestart рестарт деплоя в notifier: f krestart <svc> (rollout restart + status)
  klogin   kube login в stage-кластер: tsh17 kube login k8s.tns-stage-el
  kfw      PG-туннели: f kfw crd|push|router (старт в фоне), f kfw status, f kfw stop — crd:15432 push:15433 router:5432

  vget     секрет из Vault: f vget <path> [field] — без field: список ключей; с field: значение
  vren     продлить токен Vault (renew-self)
  vtok     обновить токен Vault: f vtok [<token>] — без аргумента берёт из буфера обмена, проверяет и сохраняет
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
        action="${1:?Использование: f kfw crd|push|router|status|stop}"
        shift || true
        FWDIR="$HOME/.k8s-fw"
        mkdir -p "$FWDIR"
        case "$action" in
            crd)
                nohup kubectl -n notifier port-forward svc/notifier-crd-pgsql-cl1-stage-haproxy 15432:5000 >"$FWDIR/crd.log" 2>&1 &
                echo $! > "$FWDIR/crd.pid"
                echo "crd: localhost:15432 -> notifier-crd-pgsql (pid $(cat "$FWDIR/crd.pid"))"
                ;;
            push)
                nohup kubectl -n notifier port-forward svc/notifier-push-wrk-pgsql-cl1-stage-haproxy 15433:5000 >"$FWDIR/push.log" 2>&1 &
                echo $! > "$FWDIR/push.pid"
                echo "push: localhost:15433 -> notifier-push-wrk-pgsql (pid $(cat "$FWDIR/push.pid"))"
                ;;
            router)
                nohup kubectl -n sender port-forward svc/sender-router-pgsql-cl1-stage-haproxy 5432:5000 >"$FWDIR/router.log" 2>&1 &
                echo $! > "$FWDIR/router.pid"
                echo "router: localhost:5432 -> sender-router-pgsql (pid $(cat "$FWDIR/router.pid"))"
                ;;
            status)
                for n in crd push router; do
                    pf="$FWDIR/$n.pid"
                    if [ -f "$pf" ] && kill -0 "$(cat "$pf")" 2>/dev/null; then
                        echo "$n: UP (pid $(cat "$pf"))"
                    else
                        echo "$n: down"
                    fi
                done
                ;;
            stop)
                for n in crd push router; do
                    pf="$FWDIR/$n.pid"
                    if [ -f "$pf" ] && kill "$(cat "$pf")" 2>/dev/null; then
                        echo "$n: stopped"
                    fi
                    rm -f "$pf"
                done
                ;;
            *)
                echo "Неизвестное действие: $action" >&2
                echo "Использование: f kfw crd|push|router|status|stop" >&2
                exit 1
                ;;
        esac
        ;;
    klogs)
        shift
        svc="${1:?Использование: f klogs <svc> [n]}"
        if [ $# -ge 2 ]; then
            exec kubectl -n notifier logs --tail="$2" -l "app.kubernetes.io/instance=$svc" --prefix "$@"
        else
            exec kubectl -n notifier logs --tail=100 -f -l "app.kubernetes.io/instance=$svc" --prefix
        fi
        ;;
    krestart)
        shift
        svc="${1:?Использование: f krestart <svc>}"
        kubectl -n notifier rollout restart "deployment/$svc"
        exec kubectl -n notifier rollout status "deployment/$svc"
        ;;
    vget)
        shift
        path="${1:?Использование: f vget <vault/path> [field]}"
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
            | jq -r '"Токен продлён, ttl=" + (.auth.lease_duration|tostring) + "f"'
        ;;
    vtok)
        shift
        newtok="${1:-}"
        [ -z "$newtok" ] && newtok="$(pbpaste 2>/dev/null || true)"
        newtok="$(printf '%s' "$newtok" | tr -d '[:space:]')"
        if [ -z "$newtok" ]; then
            echo "Использование: f vtok [<token>]" >&2
            echo "Без аргумента берёт токен из буфера обмена (pbpaste)." >&2
            exit 1
        fi
        resp="$(curl -sf --max-time 10 -H "X-Vault-Token: $newtok" "$VAULT_ADDR/v1/auth/token/lookup-self")" \
            || { echo "❌ Токен невалиден (lookup-self failed) — НЕ сохранён" >&2; exit 1; }
        printf '%s' "$newtok" > "$HOME/.vault-token"
        chmod 600 "$HOME/.vault-token"
        echo "✔ Токен сохранён в ~/.vault-token, ttl=$(printf '%s' "$resp" | jq -r '.data.ttl')с, policies: $(printf '%s' "$resp" | jq -r '.data.policies | join(",")')"
        ;;
    *)
        echo "Неизвестная команда: $cmd" >&2
        echo "Список команд: f help" >&2
        exit 1
        ;;
esac
EOF
chmod +x "$BIN_PATH"
echo "  ✔ Установлен $BIN_PATH"

# PATH для ~/.local/bin в zsh
if ensure_line_in_file "$HOME/.zshrc" ".local/bin" \
    "# f (персональный CLI-хелпер)" \
    'export PATH="$HOME/.local/bin:$PATH"'; then
    echo "  ✔ ~/.local/bin добавлен в PATH (~/.zshrc)"
else
    echo "  ⏭  PATH уже настроен."
fi

# ── Системный cron: ежечасное продление Vault-токена ─────────
# Аналог crontab-строки: 0 * * * * ~/.local/bin/f vren >> ~/.vault-renew.log 2>&1
if crontab -l 2>/dev/null | grep -qF "f vren"; then
    echo "  ⏭  Cron продления Vault-токена уже настроен."
else
    (crontab -l 2>/dev/null; echo "0 * * * * $BIN_PATH vren >> $HOME/.vault-renew.log 2>&1") | crontab -
    echo "  ✔ Добавлен cron: ежечасно продлевает Vault-токен (лог: ~/.vault-renew.log)"
fi

log_ok "Готово. Откройте новый терминал (или: source ~/.zshrc) и попробуйте: f help"
