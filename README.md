# macbook_setup

## CLI-хелпер `f`

Шаг `10_cmds.sh` создаёт персональный бинарник `~/.local/bin/f` (если путь
отсутствует в PATH — добавляет его в `~/.zshrc`). Команды работают как таргеты
в makefile: `f <команда>`.

Список команд — `f help` (или просто `f`):

| Команда | Что делает |
|---------|------------|
| `help`   | показать список команд |
| `tlog`   | логин в Teleport: `tsh17 login --proxy=tp.rwb.ru --user=haleckiy.a2` |
| `klogin` | kube login в stage-кластер: `tsh17 kube login k8s.tns-stage-el` |
| `kpods`  | поды notifier: `kubectl -n notifier get pods -o wide` |
| `kfw`    | туннели PG stage: `f kfw crd` (localhost:15432→notifier-crd), `f kfw push` (15433→push-wrk), `f kfw router` (5432→sender-router); `f kfw status` / `f kfw stop` — фон (nohup), логи и pid в `~/.k8s-fw/` |
| `klogs`  | логи сервиса notifier: `f klogs <svc>` — follow в реальном времени (все реплики); `f klogs <svc> <n>` — последние n строк (по умолчанию 100) |
| `krestart`| рестарт деплоймента notifier: `f krestart <svc>` (rollout restart + ожидание готовности) |
| `vget`   | секрет из Vault: `f vget <path> [field]` — без field покажет имена ключей, с field — значение (vault.wildberries.ru, маунт services/ — KV v1) |
| `vren`   | продлить TTL vault-токена: `f vren` |
| `vtok`   | сменить vault-токен: скопируй новый токен и выполни `f vtok` (проверит lookup и сохранит в ~/.vault-token); `f vtok <token>` — аргументом |

Чтобы добавить новую команду: впишите её ветку в `case`-блок внутри
`10_cmds.sh` (там генерируется бинарник) и дополните текст `help` и таблицу
выше. Перезапустите `10_cmds.sh` — бинарник перезапишется.
