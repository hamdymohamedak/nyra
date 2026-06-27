import "../../lib/common/domain.ny"

fn Api_health_json(meta: EnterpriseMeta) -> string {
    return Enterprise_health_json(meta)
}

fn Api_tenant_summary(rec: TenantRecord) -> i32 {
    return Tenant_name_len(rec)
}
