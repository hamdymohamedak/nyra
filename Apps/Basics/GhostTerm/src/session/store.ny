import "../core/types.ny"
import "../core/id.ny"
import "../tab/manager.ny"
import "../layout/pane.ny"
import "../profile/shell.ny"
import "../identity/profile.ny"
import "../app.ny"

extern fn i32_to_string(n: i32) -> string
extern fn strcat(a: string, b: string) -> string
extern fn strlen(s: string) -> i32

fn Session_path(name){
    let base = strcat(CONFIG_DIR, "/sessions/")
    return strcat(strcat(base, name), ".session")
}

fn Session_save(mgr, name){
    let path = Session_path(name)
    let header = strcat("GHOSTTERM_SESSION_v", i32_to_string(SESSION_VERSION))
    write_file(path, header)
    append_file(path, "\n")
    let count_line = strcat("tabs=", i32_to_string(TabManager_len(mgr)))
    append_file(path, count_line)
    append_file(path, "\n")
    let active_line = strcat("active=", i32_to_string(TabManager_active(mgr)))
    append_file(path, active_line)
    append_file(path, "\n")
    let len = Vec_i32_len(mgr.order)
    let mut i = 0
    while i < len {
        let id = Vec_i32_get(mgr.order, i)
        let tab = TabManager_load_record(mgr, id)
        let base = strcat("tab_", i32_to_string(i))
        let id_line = strcat(strcat(clone base, "_id="), i32_to_string(tab.id))
        append_file(path, id_line)
        append_file(path, "\n")
        let name_prefix = strcat(clone base, "_name=")
        append_file(path, strcat(name_prefix, tab.name))
        append_file(path, "\n")
        append_file(path, strcat(strcat(clone base, "_kind="), i32_to_string(TabKind_to_i32(tab.kind))))
        append_file(path, "\n")
        append_file(path, strcat(strcat(clone base, "_pinned="), i32_to_string(tab.pinned)))
        append_file(path, "\n")
        append_file(path, strcat(strcat(clone base, "_locked="), i32_to_string(tab.locked)))
        append_file(path, "\n")
        append_file(path, strcat(strcat(clone base, "_shell="), i32_to_string(ShellKind_to_i32(tab.shell_kind))))
        append_file(path, "\n")
        i = i + 1
    }
    print(`session saved: ${name}`, color: green)
    return 1
}

fn Session_exists(name){
    return exists(Session_path(name))
}

fn Session_field(line, prefix){
    if line.starts_with(prefix) == 0 {
        return ""
    }
    return line.replace(prefix, "")
}

fn Session_line_value(content, key){
    let lines = content.split("\n")
    for line in lines {
        if line.starts_with(key) == 1 {
            return Session_field(line, key)
        }
    }
    return ""
}

fn Session_line_i32(content, key){
    return str_to_i32(Session_line_value(content, key))
}

fn Session_tab_string(content, prefix, default_val){
    let lines = content.split("\n")
    for line in lines {
        if line.starts_with(prefix) == 1 {
            return Session_field(line, prefix)
        }
    }
    return default_val
}

fn Session_tab_i32(content, prefix){
    return str_to_i32(Session_tab_string(content, prefix, "0"))
}

fn Session_restore_tabs(name){
    if Session_exists(name) == 0 {
        print(`session "${name}" not found`, color: yellow)
        return TabManager_new()
    }
    let content = read_file(Session_path(name))
    let tab_count = Session_line_i32(content, "tabs=")
    let active_idx = Session_line_i32(content, "active=")
    if tab_count <= 0 {
        print("session file empty or corrupt", color: red)
        return TabManager_new()
    }
    let mut mgr = TabManager_new()
    let mut layout = LayoutManager_new()
    let mut i = 0
    while i < tab_count {
        let base = strcat("tab_", i32_to_string(i))
        let name_prefix = strcat(clone base, "_name=")
        let kind_prefix = strcat(clone base, "_kind=")
        let pin_prefix = strcat(clone base, "_pinned=")
        let lock_prefix = strcat(clone base, "_locked=")
        let shell_prefix = strcat(clone base, "_shell=")
        let tab_name = Session_tab_string(content, name_prefix, "restored")
        let tab_kind = Session_tab_i32(content, kind_prefix)
        let tab_pinned = Session_tab_i32(content, pin_prefix)
        let tab_locked = Session_tab_i32(content, lock_prefix)
        let tab_shell = Session_tab_i32(content, shell_prefix)
        layout = LayoutManager_create_leaf(layout, 0)
        mgr = TabManager_create(
            mgr,
            tab_name,
            TabKind_from_i32(tab_kind),
            ShellKind_from_i32(tab_shell),
            1,
            1,
            layout.root_id
        )
        let new_id = TabManager_active(mgr)
        mgr = TabManager_set_pinned(mgr, new_id, tab_pinned)
        mgr = TabManager_set_locked(mgr, new_id, tab_locked)
        i = i + 1
    }
    let order_len = Vec_i32_len(mgr.order)
    if active_idx >= 0 && active_idx < order_len {
        let aid = Vec_i32_get(mgr.order, active_idx)
        mgr = TabManager_set_active(mgr, aid)
    }
    print(`session restored: ${name} (${tab_count} tabs)`, color: green)
    return mgr
}

fn Session_restore_app(name){
    let tabs = Session_restore_tabs(name)
    if TabManager_len(tabs) == 0 {
        return GhostTermApp_new()
    }
    let layout = LayoutManager_new()
    let profiles = ProfileRegistry_seed_defaults(ProfileRegistry_new())
    let identities = IdentityRegistry_seed_defaults(IdentityRegistry_new())
    return GhostTermApp_from_tabs(layout, profiles, identities, tabs)
}

fn Session_list_placeholder(){
    print("saved sessions:")
    print("  ~/.ghostterm/sessions/*.session")
    print("  session save default | session restore default")
}
