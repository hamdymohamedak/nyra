import "sonic/core/enterprise/mod.ny"

fn main() {
    let ready = Enterprise_bootstrap()
    print(ready)
    let meta = EnterpriseMeta_new("team-api", "1.0.0", "staging")
    let name = meta.name
    let health = Service_health_body(name)
    print(health)
}
