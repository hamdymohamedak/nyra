import "../core/types.ny"
import "../core/id.ny"

extern fn map_str_str_new() -> ptr
extern fn map_str_str_insert(m: ptr, key: string, value: string) -> void
extern fn map_str_str_get(m: ptr, key: string) -> string

extern fn map_str_i32_new() -> ptr
extern fn map_str_i32_insert(m: ptr, key: string, value: i32) -> void

struct ProfileRegistry {
    names: ptr
    shells: ptr
    commands: ptr
    cwds: ptr
    ids: IdGen
    count: i32
}

fn ShellKind_to_i32(k){
    return match k {
        ShellKind.Bash => 0
        ShellKind.Zsh => 1
        ShellKind.Fish => 2
        ShellKind.PowerShell => 3
        ShellKind.Cmd => 4
        ShellKind.Nushell => 5
        ShellKind.Wsl => 6
        ShellKind.Ssh => 7
        ShellKind.Custom => 8
    }
}

fn ProfileRegistry_new(){
    return ProfileRegistry {
        names: map_str_str_new()
        shells: map_str_i32_new()
        commands: map_str_str_new()
        cwds: map_str_str_new()
        ids: IdGen_new()
        count: 0
    }
}

fn ProfileRegistry_add(reg, name, shell, command, cwd){
    let id = IdGen_take(reg.ids)
    let key = Id_to_key(id)
    map_str_str_insert(reg.names, key, name)
    map_str_i32_insert(reg.shells, key, ShellKind_to_i32(shell))
    map_str_str_insert(reg.commands, key, command)
    map_str_str_insert(reg.cwds, key, cwd)
    return ProfileRegistry {
        names: reg.names
        shells: reg.shells
        commands: reg.commands
        cwds: reg.cwds
        ids: IdGen_next(reg.ids)
        count: reg.count + 1
    }
}

fn ProfileRegistry_print(_reg){
    print("shell profiles (built-in presets):")
    print("  #1 local-bash   (bash)")
    print("  #2 local-zsh     (zsh)")
    print("  #3 wsl-ubuntu    (wsl)")
    print("  #4 ssh-default   (ssh)")
    print("  #5 powershell    (powershell)")
}

fn ProfileRegistry_seed_defaults(reg){
    let r1 = ProfileRegistry_add(reg, "local-bash", ShellKind.Bash, "/bin/bash", "~")
    let r2 = ProfileRegistry_add(r1, "local-zsh", ShellKind.Zsh, "/bin/zsh", "~")
    let r3 = ProfileRegistry_add(r2, "wsl-ubuntu", ShellKind.Wsl, "wsl.exe -d Ubuntu", "~")
    let r4 = ProfileRegistry_add(r3, "ssh-default", ShellKind.Ssh, "ssh", "~")
    return ProfileRegistry_add(r4, "powershell", ShellKind.PowerShell, "pwsh", "~")
}
