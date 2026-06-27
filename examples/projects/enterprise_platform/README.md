# Enterprise platform workspace

Reference layout for **50+ developer** Nyra monorepos: shared `lib/`, service modules, `nyra.mod`, and ownership-safe strings across files.

## Layout

```
enterprise_platform/
  nyra.mod              # module manifest + stdlib requires
  main.ny               # entry (compile-only smoke; no blocking listen)
  lib/common/           # shared domain + config
  services/api/         # HTTP-facing handlers
  services/worker/      # background / shared-state jobs (Arc<string>)
```

## Build & test

```bash
nyra check examples/projects/enterprise_platform/main.ny
cargo test -p compiler conf_ent
bash scripts/enterprise-check.sh
```

## Ownership notes

- `TenantRecord` uses composite auto-drop for `string` fields.
- `Arc_from_string` in worker module demonstrates shared labels without manual `Drop`.
- `spawn` + `await` bootstrap requires **Send** captures (see `webDocs/enterprise.html`).

## Out of scope (integrate externally)

- Distributed tracing (OpenTelemetry, Jaeger)
- Service mesh (Istio, Linkerd)
- Centralized config (Vault, etcd)

Nyra provides compile-time ownership + workspace structure; wire observability at deploy time.
