
struct PrivateIsolation {
    separate_history: i32
    separate_env: i32
    separate_git_creds: i32
    separate_ssh_agent: i32
    separate_cache: i32
    destroy_on_close: i32
}

fn PrivateIsolation_default(){
    return PrivateIsolation {
        separate_history: 1
        separate_env: 1
        separate_git_creds: 1
        separate_ssh_agent: 1
        separate_cache: 1
        destroy_on_close: 1
    }
}

fn PrivateIsolation_destroy_notice(){
    print("private tab closed — session destroyed", color: dim)
    print("  history, cache, temp files, and credentials wiped", color: dim)
}

struct SandboxPolicy {
    no_internet: i32
    no_home_access: i32
    no_clipboard: i32
    no_ssh: i32
    no_git_creds: i32
    read_only_fs: i32
    max_ram_mb: i32
    max_cpu_percent: i32
}

fn SandboxPolicy_strict(){
    return SandboxPolicy {
        no_internet: 1
        no_home_access: 1
        no_clipboard: 1
        no_ssh: 1
        no_git_creds: 1
        read_only_fs: 1
        max_ram_mb: 512
        max_cpu_percent: 50
    }
}

fn SandboxPolicy_relaxed(){
    return SandboxPolicy {
        no_internet: 0
        no_home_access: 0
        no_clipboard: 0
        no_ssh: 0
        no_git_creds: 0
        read_only_fs: 0
        max_ram_mb: 2048
        max_cpu_percent: 100
    }
}

fn SandboxPolicy_print(policy){
    print("sandbox policy:")
    print(`  no_internet=${policy.no_internet} no_home=${policy.no_home_access} no_clipboard=${policy.no_clipboard}`)
    print(`  no_ssh=${policy.no_ssh} read_only=${policy.read_only_fs} ram_mb=${policy.max_ram_mb} cpu=${policy.max_cpu_percent}%`)
}

fn DisposableTab_on_close(){
    print("disposable tab closed — no trace left", color: dim)
}
