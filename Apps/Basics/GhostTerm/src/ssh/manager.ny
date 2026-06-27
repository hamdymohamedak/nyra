extern fn map_str_str_new() -> ptr
extern fn map_str_str_insert(m: ptr, key: string, value: string) -> void
extern fn map_str_str_get(m: ptr, key: string) -> string
extern fn i32_to_string(n: i32) -> string
extern fn strcat(a: string, b: string) -> string

struct SshHost {
    id: i32
    name: string
    user: string
    host: string
    port: i32
    group: string
}

struct SshManager {
    hosts: ptr
    next_id: i32
}

fn SshManager_new(){
    return SshManager {
        hosts: map_str_str_new()
        next_id: 1
    }
}

fn SshManager_add(mgr, _name, user, host, port, _group){
    let key = i32_to_string(mgr.next_id)
    let entry = strcat(strcat(strcat(strcat(user, "@"), host), ":"), i32_to_string(port))
    map_str_str_insert(mgr.hosts, key, entry)
    return SshManager {
        hosts: mgr.hosts
        next_id: mgr.next_id + 1
    }
}

fn SshManager_seed(mgr){
    let m1 = SshManager_add(mgr, "production", "root", "prod.example.com", 22, "Production")
    let m2 = SshManager_add(m1, "database", "dbadmin", "db.internal", 22, "Database")
    return SshManager_add(m2, "dev-ubuntu", "ubuntu", "dev.example.com", 22, "Dev")
}

fn SshManager_print(_mgr){
    print("SSH manager — one-click connect:", color: bold)
    print("  [Production]  root@prod.example.com")
    print("  [Database]    dbadmin@db.internal")
    print("  [Dev]         ubuntu@dev.example.com")
    print("  command: ssh connect <id>")
}

fn SshManager_connect(id){
    print(`connecting SSH host #${id}...`, color: green)
}
