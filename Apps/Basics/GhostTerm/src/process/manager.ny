extern fn map_str_i32_new() -> ptr
extern fn map_str_i32_insert(m: ptr, key: string, value: i32) -> void
extern fn i32_to_string(n: i32) -> string

struct ProcessEntry {
    pid: i32
    name: string
    cpu_percent: i32
    ram_mb: i32
}

struct ProcessManager {
    table: ptr
}

fn ProcessManager_new(){
    return ProcessManager { table: map_str_i32_new() }
}

fn ProcessManager_seed(mgr){
    map_str_i32_insert(mgr.table, "bash", 1234)
    map_str_i32_insert(mgr.table, "node", 5678)
    map_str_i32_insert(mgr.table, "docker", 9012)
    return mgr
}

fn ProcessManager_print(_mgr){
    print("running processes:", color: bold)
    print("  PID     NAME        CPU    RAM")
    print("  1234    bash        2%     12MB")
    print("  5678    node        15%    128MB")
    print("  9012    docker       8%     64MB")
    print("  command: process kill <pid>")
}

fn ProcessManager_kill(pid){
    print(`sent SIGTERM to pid ${pid}`, color: yellow)
}
