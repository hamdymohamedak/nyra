# Networking apps — Nyra language smoke tests

Each directory is an independent **`nyra pkg init` project**. Apps use the **auto-prelude** stdlib.

## Stdlib coverage (v1.16.0+)

| API | Module |
|-----|--------|
| `dns_lookup` | `stdlib/net/dns.ny` |
| `ping_tcp`, `ping_icmp`, `ping_auto`, `ping_auto_verbose` | `stdlib/net/icmp.ny` |
| `ping_icmp_system`, `ping_icmp_capable` | `stdlib/net/icmp.ny` |
| `ws_listen_on`, `ws_listen_tls_on`, `ws_listen_dev_on`, `ws_accept`, `ws_accept_tls` | `stdlib/net/websocket.ny` |
| `ws_listen_prod_on` | `stdlib/net/websocket.ny`, `stdlib/net/tls_prod.ny` |
| `Ftp_login`, `Ftp_list`, `Ftp_retr`, `Ftp_stor` | `stdlib/net/ftp.ny` |
| `tcp_accept_wait`, `tcp_connect_timeout` | `stdlib/net/tcp.ny` |
| `Smtp_send`, `Smtp_send_tls`, `Smtp_send_starttls` | `stdlib/net/smtp.ny` |
| `tls_upgrade_fd`, `tls_require`, `tls_dev_ensure`, `tls_listen_dev` | `stdlib/tls.ny`, `stdlib/net/tls_dev.ny` |
| `tls_connect_verify`, `tls_listen_prod`, `tls_connect_prod`, `tls_validate_pem` | `stdlib/tls.ny`, `stdlib/net/tls_prod.ny` |
| `HttpRouter_register_slot`, `serve_handlers`, `Http_dispatch_slot` | `stdlib/net/http/` |
| `HttpPool`, `HttpPool_get` (HTTP + HTTPS keep-alive) | `stdlib/net/http/pool.ny` |
| `TtlCache`, `TtlCache_put`, `TtlCache_get` | `stdlib/net/cache.ny` |
| `TcpHub` (`Send`), `Channel_str` | `stdlib/net/hub.ny`, `stdlib/sync/channel.ny` |
| `tcp_relay_poll` | `stdlib/net/poll.ny` |
| `HashMap_str_*` (refcount + safe reassignment) | `stdlib/map.ny` |

## Projects

| App | Stdlib highlight |
|-----|------------------|
| `DnsLookup` | `dns_lookup` |
| `Ping` | `ping_auto` |
| `PortScanner` | `tcp_connect_timeout` |
| `WebSocketServer` | `ws_listen_on` / `ws_listen_tls_on` |
| `FtpClient` | `Ftp_retr` |
| `SmtpClient` | `Smtp_send_starttls` (587) |
| `HTTPClient` | `HttpPool` (`-P` flag, HTTPS reuse) |
| `HTTPServer` | `serve_handlers` + zero-types handler |
| `ChatServer` | `spawn` + `TcpHub` struct capture |
| `CdnCache` | `TtlCache` TTL + disk tier |
| `TcpProxy` | `tcp_relay_poll` |

Build all:

```bash
BASE="Apps/Networking apps"
for d in HTTPServer HTTPClient RestAPI WebSocketServer ChatServer ChatClient \
         FtpClient DnsLookup Ping PortScanner SmtpClient TcpProxy ReverseProxy CdnCache; do
  (cd "$BASE/$d" && nyra build .) || exit 1
done
```

## Resolved (v1.14.0)

| Gap | Fix |
|-----|-----|
| `spawn` + struct captures | `Send` on `TcpStream` / `TcpHub`; constructor type inference; spawn IR type hoist |
| Handler fn in zero-types | Callback call-site inference for `serve_handlers` handler param |
| HTTP pool HTTPS | `HttpPool` reuses TLS handles (`tls_connect` + keep-alive) |
| `wss://` listener | `ws_listen_tls_on` + `ws_accept_tls` |
| CDN disk / TTL | `stdlib/net/cache.ny` + `CdnCache` app |

## Resolved (v1.20.0) — production networking

| Gap | Fix |
|-----|-----|
| TLS client skipped cert verification | `tls_connect_verify` / `tls_connect_ca`; HttpPool, HTTP client, SMTP use verify by default |
| Production `wss` / HTTPS server cert workflow | `stdlib/net/tls_prod.ny` — `NYRA_TLS_CERT`, `NYRA_TLS_KEY`, `tls_listen_prod`, `ws_listen_prod_on` |
| PEM misconfiguration at listen time | `tls_validate_pem` + `tls_last_error` before `tls_listen` |
| `ping_icmp` needs root on many systems | Linux unprivileged ICMP when allowed; `ping_icmp_system` OS fallback; `ping_icmp_capable` |

**Environment notes:** macOS still requires root or system `ping` for ICMP; Windows uses TCP/system ping only.

## Resolved (v1.16.0) — runtime / environment polish

| Limitation | Mitigation |
|------------|------------|
| HTTPS / `wss` needs OpenSSL | `tls_require()` clear error; `tls_dev_ensure` + `ws_listen_dev_on` for local self-signed certs |
| `ping_icmp` needs root | `ping_auto_verbose` / `ping_icmp_hint` — TCP fallback with explanation |
| `HashMap` / `TtlCache_put` double-free on reassignment | Refcounted map handles + in-place `TtlCache_put`; custom `Drop` passes struct pointer |
| LLVM instability on large programs | PHI / `loop.latch` tests green; custom drop ABI fix removes HashMap shutdown crashes |

**Environment notes (not language gaps):** production `wss` still needs real cert/key files; ICMP remains root-only by OS policy.
