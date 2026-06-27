import "lib/common/config.ny"
import "lib/common/domain.ny"
import "services/api/handlers.ny"
import "services/worker/jobs.ny"

fn main() {
    let ready = Enterprise_bootstrap()
    print(ready)

    let meta = EnterpriseMeta_default()
    let tenant = TenantRecord_new(42, "acme-corp")
    print(Api_tenant_summary(tenant))

    let health = Api_health_json(meta)
    print(health)

    let label = Worker_shared_label("batch-export")
    print(label)
}
