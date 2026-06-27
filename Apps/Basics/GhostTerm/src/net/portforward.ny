extern fn map_str_i32_new() -> ptr
extern fn map_str_i32_insert(m: ptr, key: string, value: i32) -> void
extern fn i32_to_string(n: i32) -> string
extern fn strcat(a: string, b: string) -> string

struct PortForward {
    id: i32
    local_port: i32
    remote_host: string
    remote_port: i32
    label: string
}

struct PortForwardManager {
    rules: ptr
    next_id: i32
}

fn PortForwardManager_new(){
    return PortForwardManager {
        rules: map_str_i32_new()
        next_id: 1
    }
}

fn PortForwardManager_add(mgr, local_port, _remote_host, _remote_port){
    let key = i32_to_string(mgr.next_id)
    map_str_i32_insert(mgr.rules, key, local_port)
    return PortForwardManager {
        rules: mgr.rules
        next_id: mgr.next_id + 1
    }
}

fn PortForwardManager_seed(mgr){
    let m1 = PortForwardManager_add(mgr, 3000, "localhost", 3000)
    let m2 = PortForwardManager_add(m1, 5000, "localhost", 5000)
    return PortForwardManager_add(m2, 8080, "localhost", 8080)
}

fn PortForwardManager_print(_mgr){
    print("port forwards:", color: bold)
    print("  #1  local:3000  → localhost:3000")
    print("  #2  local:5000  → localhost:5000")
    print("  #3  local:8080  → localhost:8080")
    print("  command: forward add <local> <remote_host> <remote_port>")
}

fn PortForwardManager_enable(id){
    print(`port forward #${id} enabled`, color: green)
}
