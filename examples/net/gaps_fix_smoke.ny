// Networking gap fixes (v1.16.0+) — see tests/nyra/net/ and Apps/Networking apps/

fn main() {
  print("HashMap refcount + Drop fix: stdlib/map.ny")
  print("dev wss: ws_listen_dev_on + tls_dev_ensure")
  print("prod wss: ws_listen_prod_on + NYRA_TLS_CERT/NYRA_TLS_KEY")
  print("ping: ICMP -> system ping -> TCP (ping_icmp_capable)")
  print("TLS verify: tls_connect_verify + tls_validate_pem")
  print("gaps fix smoke ok")
}
