import "stdlib/strings.ny"

struct TenantRecord Send {
    id: i32
    name: string
}

fn TenantRecord_new(id: i32, name: string) -> TenantRecord {
    return TenantRecord { id: id, name: name }
}

fn Tenant_display_id(rec: TenantRecord) -> i32 {
    return rec.id
}

fn Tenant_name_len(rec: TenantRecord) -> i32 {
    return strlen(rec.name)
}
