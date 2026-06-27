import "sonic/core/enterprise/mod.ny"

fn EnterpriseMeta_default() -> EnterpriseMeta {
    return EnterpriseMeta_new("platform-api", "2.7.0", "production")
}
