import "sonic/core/microservice.ny"

fn main() {
    let cfg = ServiceConfig_new("orders-api", "127.0.0.1", 8080)
    let ready = Service_bootstrap_async()
    print(ready)
    let name = cfg.name
    print(Service_health_body(name))
}
