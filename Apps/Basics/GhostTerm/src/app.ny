import "core/types.ny"
import "tab/manager.ny"
import "layout/pane.ny"
import "profile/shell.ny"
import "identity/profile.ny"
import "isolation/policy.ny"

struct GhostTermApp {
    tabs: TabManager
    layout: LayoutManager
    profiles: ProfileRegistry
    identities: IdentityRegistry
    theme: ThemeMode
    gpu_enabled: i32
    running: i32
}

fn GhostTermApp_new(){
    let profiles = ProfileRegistry_seed_defaults(ProfileRegistry_new())
    let identities = IdentityRegistry_seed_defaults(IdentityRegistry_new())
    let layout = LayoutManager_new()
    let tabs = TabManager_new()
    let with_layout = LayoutManager_create_leaf(layout, 0)
    let with_tab = TabManager_create(tabs, "main", TabKind.Standard, ShellKind.Bash, 1, 1, with_layout.root_id)
    let layout2 = LayoutManager_create_leaf(with_layout, with_tab.active_id)
    return GhostTermApp {
        tabs: with_tab
        layout: layout2
        profiles: profiles
        identities: identities
        theme: ThemeMode.Dark
        gpu_enabled: 1
        running: 1
    }
}

fn GhostTermApp_new_tab(app, name, kind){
    let layout = LayoutManager_create_leaf(app.layout, 0)
    let tabs = TabManager_create(app.tabs, name, kind, ShellKind.Bash, 1, 1, layout.root_id)
    return GhostTermApp {
        tabs: tabs
        layout: layout
        profiles: app.profiles
        identities: app.identities
        theme: app.theme
        gpu_enabled: app.gpu_enabled
        running: app.running
    }
}

fn GhostTermApp_new_private_tab(app, name){
    let _iso = PrivateIsolation_default()
    print("creating private tab — isolated history, env, git, ssh", color: magenta)
    return GhostTermApp_new_tab(app, name, TabKind.Private)
}

fn GhostTermApp_new_sandbox_tab(app, name){
    SandboxPolicy_print(SandboxPolicy_strict())
    return GhostTermApp_new_tab(app, name, TabKind.Sandbox)
}

fn GhostTermApp_new_disposable_tab(app, name){
    print("creating disposable tab — vanishes on close", color: yellow)
    return GhostTermApp_new_tab(app, name, TabKind.Disposable)
}

fn GhostTermApp_split_active(app, dir){
    let active = TabManager_active(app.tabs)
    if active == 0 {
        return app
    }
    let tab = TabManager_load_record(app.tabs, active)
    let layout = LayoutManager_split(app.layout, tab.pane_id, dir, active)
    return GhostTermApp {
        tabs: app.tabs
        layout: layout
        profiles: app.profiles
        identities: app.identities
        theme: app.theme
        gpu_enabled: app.gpu_enabled
        running: app.running
    }
}

fn GhostTermApp_status(app){
    print("\n--- GhostTerm status ---", color: bold)
    print(`tabs: ${TabManager_len(app.tabs)}  active: #${TabManager_active(app.tabs)}`)
    print(`theme: dark  gpu: ${app.gpu_enabled}`)
    print("open tabs:")
    TabManager_print(app.tabs)
    LayoutManager_print(app.layout)
}

fn GhostTermApp_show_roadmap(){
    print("\n--- feature roadmap (from project plan) ---", color: cyan)
    print("  [core]     tabs, splits, sessions, profiles, workspaces")
    print("  [shell]    bash, zsh, fish, powershell, nushell, wsl, ssh")
    print("  [search]   scrollback search (Ctrl+Shift+F)")
    print("  [history]  unlimited + favorites + pin")
    print("  [gpu]      Metal/OpenGL/Vulkan renderer")
    print("  [identity] per-tab git/aws/ssh profiles")
    print("  [private]  isolated + destroy on close")
    print("  [sandbox]  network/fs/ram/cpu restrictions")
    print("  [ai]       command explain + error fix")
    print("  [ext]      plugins, macros, broadcast, recording")
}

fn GhostTermApp_stop(app){
    return GhostTermApp {
        tabs: app.tabs
        layout: app.layout
        profiles: app.profiles
        identities: app.identities
        theme: app.theme
        gpu_enabled: app.gpu_enabled
        running: 0
    }
}

fn GhostTermApp_with_tabs(app, tabs){
    return GhostTermApp {
        tabs: tabs
        layout: app.layout
        profiles: app.profiles
        identities: app.identities
        theme: app.theme
        gpu_enabled: app.gpu_enabled
        running: app.running
    }
}

fn GhostTermApp_rename_active(app, name){
    let id = TabManager_active(app.tabs)
    let tabs = TabManager_rename(app.tabs, id, name)
    return GhostTermApp_with_tabs(app, tabs)
}

fn GhostTermApp_pin_active(app, pinned){
    let id = TabManager_active(app.tabs)
    let tabs = TabManager_set_pinned(app.tabs, id, pinned)
    return GhostTermApp_with_tabs(app, tabs)
}

fn GhostTermApp_lock_active(app, locked){
    let id = TabManager_active(app.tabs)
    let tabs = TabManager_set_locked(app.tabs, id, locked)
    return GhostTermApp_with_tabs(app, tabs)
}

fn GhostTermApp_duplicate_active(app){
    let id = TabManager_active(app.tabs)
    let tabs = TabManager_duplicate(app.tabs, id)
    return GhostTermApp_with_tabs(app, tabs)
}

fn GhostTermApp_close_active(app){
    let id = TabManager_active(app.tabs)
    let tab = TabManager_load_record(app.tabs, id)
    if tab.kind == TabKind.Disposable {
        print("destroying disposable tab session", color: yellow)
    }
    if tab.kind == TabKind.Private {
        print("destroying private tab — history/credentials wiped", color: magenta)
    }
    let tabs = TabManager_destroy(app.tabs, id)
    return GhostTermApp_with_tabs(app, tabs)
}

fn GhostTermApp_switch_tab(app, id){
    let tabs = TabManager_set_active(app.tabs, id)
    return GhostTermApp_with_tabs(app, tabs)
}

fn GhostTermApp_from_tabs(layout, profiles, identities, tabs){
    return GhostTermApp {
        tabs: tabs
        layout: layout
        profiles: profiles
        identities: identities
        theme: ThemeMode.Dark
        gpu_enabled: 1
        running: 1
    }
}
