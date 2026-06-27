# ny-redis

NyraPkg binding for [hiredis](https://github.com/redis/hiredis) — thin FFI, no RESP rewrite in Nyra.

## Install

```bash
nyra pkg install ny-redis@^0.1.0
```

Or copy this directory and add to your project:

```nyra
require ny-redis@^0.1.0
import "pkg/ny-redis/redis.ny"
```

## Build deps

- macOS: `brew install hiredis`
- Debian: `libhiredis-dev`

## API

- `Redis_connect(host, port)` → connection handle
- `Redis_get` / `Redis_set` / `Redis_del` / `Redis_ping`
- `Redis_lpush` / `Redis_brpop` — list queue helpers
- `Redis_close`

Smoke test: `nyra build . && ./target/debug/main` (skips if Redis is down).
