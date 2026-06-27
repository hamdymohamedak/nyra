import "../core/types.ny"
import "../core/id.ny"

extern fn map_str_i32_new() -> ptr
extern fn map_str_i32_insert(m: ptr, key: string, value: i32) -> void
extern fn map_str_i32_get(m: ptr, key: string) -> i32
extern fn map_str_i32_contains(m: ptr, key: string) -> i32
extern fn map_str_i32_free(m: ptr) -> void

extern fn map_str_str_new() -> ptr
extern fn map_str_str_insert(m: ptr, key: string, value: string) -> void
extern fn map_str_str_get(m: ptr, key: string) -> string
extern fn map_str_str_contains(m: ptr, key: string) -> i32
extern fn map_str_str_free(m: ptr) -> void

extern fn strcat(a: string, b: string) -> string

struct TabRecord {
    id: i32
    name: string
    kind: TabKind
    pinned: i32
    locked: i32
    shell_kind: ShellKind
    profile_id: i32
    identity_id: i32
    pane_id: i32
    workspace_id: i32
}

fn TabKind_to_i32(k){
    return match k {
        TabKind.Standard => 0
        TabKind.Private => 1
        TabKind.Sandbox => 2
        TabKind.Disposable => 3
    }
}

fn TabKind_from_i32(n){
    if n == 1 { return TabKind.Private }
    if n == 2 { return TabKind.Sandbox }
    if n == 3 { return TabKind.Disposable }
    return TabKind.Standard
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

fn ShellKind_from_i32(n){
    if n == 1 { return ShellKind.Zsh }
    if n == 2 { return ShellKind.Fish }
    if n == 3 { return ShellKind.PowerShell }
    if n == 4 { return ShellKind.Cmd }
    if n == 5 { return ShellKind.Nushell }
    if n == 6 { return ShellKind.Wsl }
    if n == 7 { return ShellKind.Ssh }
    if n == 8 { return ShellKind.Custom }
    return ShellKind.Bash
}

fn TabKind_label(k){
    return match k {
        TabKind.Standard => "standard"
        TabKind.Private => "private"
        TabKind.Sandbox => "sandbox"
        TabKind.Disposable => "disposable"
    }
}

struct TabManager {
    order: ptr
    names: ptr
    kinds: ptr
    pinned: ptr
    locked: ptr
    shells: ptr
    profiles: ptr
    identities: ptr
    panes: ptr
    ids: IdGen
    active_id: i32
    count: i32
}

fn TabManager_new(){
    return TabManager {
        order: Vec_i32_new()
        names: map_str_str_new()
        kinds: map_str_i32_new()
        pinned: map_str_i32_new()
        locked: map_str_i32_new()
        shells: map_str_i32_new()
        profiles: map_str_i32_new()
        identities: map_str_i32_new()
        panes: map_str_i32_new()
        ids: IdGen_new()
        active_id: 0
        count: 0
    }
}

fn TabManager_write_meta(mgr: TabManager, tab: TabRecord){
    let key = Id_to_key(tab.id)
    map_str_str_insert(mgr.names, key, tab.name)
    map_str_i32_insert(mgr.kinds, key, TabKind_to_i32(tab.kind))
    map_str_i32_insert(mgr.pinned, key, tab.pinned)
    map_str_i32_insert(mgr.locked, key, tab.locked)
    map_str_i32_insert(mgr.shells, key, ShellKind_to_i32(tab.shell_kind))
    map_str_i32_insert(mgr.profiles, key, tab.profile_id)
    map_str_i32_insert(mgr.identities, key, tab.identity_id)
    map_str_i32_insert(mgr.panes, key, tab.pane_id)
}

fn TabManager_load_record(mgr: TabManager, tab_id: i32) -> TabRecord {
    let key = Id_to_key(tab_id)
    return TabRecord {
        id: tab_id
        name: map_str_str_get(mgr.names, key)
        kind: TabKind_from_i32(map_str_i32_get(mgr.kinds, key))
        pinned: map_str_i32_get(mgr.pinned, key)
        locked: map_str_i32_get(mgr.locked, key)
        shell_kind: ShellKind_from_i32(map_str_i32_get(mgr.shells, key))
        profile_id: map_str_i32_get(mgr.profiles, key)
        identity_id: map_str_i32_get(mgr.identities, key)
        pane_id: map_str_i32_get(mgr.panes, key)
        workspace_id: 0
    }
}

fn TabManager_has(mgr, id){
    let key = Id_to_key(id)
    return map_str_str_contains(mgr.names, key)
}

fn TabManager_create(mgr, name, kind, shell, profile_id, identity_id, pane_id){
    if mgr.count >= MAX_TABS {
        print("tab limit reached", color: red)
        return mgr
    }
    let id = IdGen_take(mgr.ids)
    let tab = TabRecord {
        id: id
        name: name
        kind: kind
        pinned: 0
        locked: 0
        shell_kind: shell
        profile_id: profile_id
        identity_id: identity_id
        pane_id: pane_id
        workspace_id: 0
    }
    Vec_i32_push(mgr.order, id)
    TabManager_write_meta(mgr, tab)
    return TabManager {
        order: mgr.order
        names: mgr.names
        kinds: mgr.kinds
        pinned: mgr.pinned
        locked: mgr.locked
        shells: mgr.shells
        profiles: mgr.profiles
        identities: mgr.identities
        panes: mgr.panes
        ids: IdGen_next(mgr.ids)
        active_id: id
        count: mgr.count + 1
    }
}

fn TabManager_rename(mgr, id, name){
    if TabManager_has(mgr, id) == 0 {
        return mgr
    }
    let key = Id_to_key(id)
    map_str_str_insert(mgr.names, key, name)
    return mgr
}

fn TabManager_set_pinned(mgr, id, pinned){
    if TabManager_has(mgr, id) == 0 {
        return mgr
    }
    let key = Id_to_key(id)
    map_str_i32_insert(mgr.pinned, key, pinned)
    return mgr
}

fn TabManager_set_locked(mgr, id, locked){
    if TabManager_has(mgr, id) == 0 {
        return mgr
    }
    let key = Id_to_key(id)
    map_str_i32_insert(mgr.locked, key, locked)
    return mgr
}

fn TabManager_set_active(mgr, id){
    if TabManager_has(mgr, id) == 0 {
        return mgr
    }
    return TabManager {
        order: mgr.order
        names: mgr.names
        kinds: mgr.kinds
        pinned: mgr.pinned
        locked: mgr.locked
        shells: mgr.shells
        profiles: mgr.profiles
        identities: mgr.identities
        panes: mgr.panes
        ids: mgr.ids
        active_id: id
        count: mgr.count
    }
}

fn TabManager_duplicate(mgr, id){
    if TabManager_has(mgr, id) == 0 {
        return mgr
    }
    let src = TabManager_load_record(mgr, id)
    let copy_name = strcat(clone src.name, " (copy)")
    let created = TabManager_create(mgr, copy_name, src.kind, src.shell_kind, src.profile_id, src.identity_id, src.pane_id)
    return TabManager_set_pinned(created, TabManager_active(created), src.pinned)
}

fn TabManager_destroy(mgr, id){
    if TabManager_has(mgr, id) == 0 {
        return mgr
    }
    let tab = TabManager_load_record(mgr, id)
    if tab.locked == 1 {
        print("tab is locked", color: yellow)
        return mgr
    }
    let len = Vec_i32_len(mgr.order)
    let fresh = Vec_i32_new()
    let mut i = 0
    while i < len {
        let cur = Vec_i32_get(mgr.order, i)
        if cur != id {
            Vec_i32_push(fresh, cur)
        }
        i = i + 1
    }
    Vec_i32_free(mgr.order)
    let next_active = if Vec_i32_len(fresh) > 0 { Vec_i32_get(fresh, 0) } else { 0 }
    return TabManager {
        order: fresh
        names: mgr.names
        kinds: mgr.kinds
        pinned: mgr.pinned
        locked: mgr.locked
        shells: mgr.shells
        profiles: mgr.profiles
        identities: mgr.identities
        panes: mgr.panes
        ids: mgr.ids
        active_id: next_active
        count: mgr.count - 1
    }
}

fn TabManager_len(mgr){
    return mgr.count
}

fn TabManager_active(mgr) -> i32 {
    return mgr.active_id
}

fn TabManager_print(mgr){
    let len = Vec_i32_len(mgr.order)
    let mut i = 0
    while i < len {
        let id = Vec_i32_get(mgr.order, i)
        let tab = TabManager_load_record(mgr, id)
        let pin = if tab.pinned == 1 { " [pinned]" } else { "" }
        let lock = if tab.locked == 1 { " [locked]" } else { "" }
        let active = if id == mgr.active_id { " *" } else { "" }
        print(`  #${tab.id} ${tab.name} (${TabKind_label(tab.kind)})${pin}${lock}${active}`)
        i = i + 1
    }
}
