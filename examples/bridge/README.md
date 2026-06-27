# Language bridge (Python / Node / Java)

Nyra calls other language ecosystems via **subprocess workers** and a **JSON line protocol**.

## Run

```bash
cd examples/bridge
chmod +x workers/*.sh workers/*.py workers/*.mjs
javac workers/BridgeWorker.java -d workers
nyra run .
```

Requires on `PATH`: `python3`, `node`, `java`.

## Protocol

1. Nyra writes one JSON line to worker stdin (via `bridge_exec_arg`).
2. Worker prints one JSON line to stdout: `{"ok":true,"result":"..."}`.
3. Nyra reads stdout into a heap `string` (caller owns via auto-drop).

## Nyra API

```ny
import "stdlib/bridge/mod.ny"

let req = bridge_op_add(1, 2)
let out = bridge_exec_arg("python3", "workers/bridge_worker.py", req)
print(bridge_result(out))
```

## Use real libraries

Extend workers to import **pip** / **npm** / **Maven** packages:

| Worker | Install deps | Example |
|--------|----------------|---------|
| Python | `pip install numpy` in venv | `numpy` linear algebra in `bridge_worker.py` |
| Node | `npm install lodash` | `require('lodash')` in `bridge_worker.mjs` |
| Java | `pom.xml` + fat jar | call static methods from worker `main` |

Keep heavy logic in workers; Nyra stays the orchestrator.

## Reverse: host calls Nyra

Other languages load Nyra **`export fn`** via cdylib:

```bash
nyra build examples/ffi/export_greet/main.ny -o libnyra_greet --cdylib
python3 examples/ffi/export_greet/python_host/call.py
node examples/ffi/export_greet/node_host/call.mjs   # needs: npm install
```

See [`docs/bridge.md`](../../docs/bridge.md).
