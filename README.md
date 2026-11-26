# macbook_setup

## CLI-хелпер `c`

Шаг `10_cmds.sh` создаёт персональный бинарник `~/.local/bin/c` (если путь
отсутствует в PATH — добавляет его в `~/.zshrc`). Команды работают как таргеты
в makefile: `c <команда>`.

Список команд — `c help` (или просто `c`):

| Команда | Что делает |
|---------|------------|
| `help`   | показать список команд |
| `tlog`   | логин в Teleport: `tsh17 login --proxy=tp.rwb.ru --user=haleckiy.a2` |
| `klogin` | kube login в stage-кластер: `tsh17 kube login k8s.tns-stage-el` |
| `kpods`  | поды notifier: `kubectl -n notifier get pods -o wide` |
| `kfw`    | port-forward PG stage: `kubectl -n sender port-forward svc/sender-router-pgsql-cl1-stage-haproxy 5432:5000` (мастер; 5001 replicas, 5002 replicasync, 5003 replicaasync) |
| `klogs`  | логи сервиса notifier: `c klogs <svc>` — follow в реальном времени (все реплики); `c klogs <svc> <n>` — последние n строк (по умолчанию 100) |
| `krestart`| рестарт деплоймента notifier: `c krestart <svc>` (rollout restart + ожидание готовности) |
| `vget`   | секрет из Vault: `c vget <path> [field]` — без field покажет имена ключей, с field — значение (vault.wildberries.ru, маунт services/ — KV v1) |
| `vren`   | продлить TTL vault-токена: `c vren` |
| `vtok`   | сменить vault-токен: скопируй новый токен и выполни `c vtok` (проверит lookup и сохранит в ~/.vault-token); `c vtok <token>` — аргументом |

Чтобы добавить новую команду: впишите её ветку в `case`-блок внутри
`10_cmds.sh` (там генерируется бинарник) и дополните текст `help` и таблицу
выше. Перезапустите `10_cmds.sh` — бинарник перезапишется.
