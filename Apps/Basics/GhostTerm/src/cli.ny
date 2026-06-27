import "app.ny"
import "ui/banner.ny"
import "session/store.ny"
import "features/palette.ny"
import "identity/profile.ny"
import "profile/shell.ny"
import "terminal/highlight.ny"
import "terminal/scrollback.ny"
import "ssh/manager.ny"
import "net/portforward.ny"
import "process/manager.ny"
import "ai/explain.ny"
import "ai/fix.ny"
import "ext/plugin.ny"
import "macro/recorder.ny"
import "broadcast/sender.ny"
import "terminal/io.ny"
import "shell/spawn.ny"

fn Gpu_run_interactive_stub(){
    print("GPU mode requires raylib — run from Apps/GhostTerm/gpu:", color: yellow)
    print("  cd gpu && nyra run .", color: dim)
}

fn Gpu_run_demo_stub(){
    Gpu_run_interactive_stub()
}

extern fn strlen(s: string) -> i32
extern fn strcmp(a: string, b: string) -> i32

fn Cli_eq(a, b){
    if strcmp(a, b) == 0 {
        return 1
    }
    return 0
}

fn Cli_is_meta_command(line){
    if strlen(line) == 0 {
        return 0
    }
    if Cli_eq(line, "help") == 1 || Cli_eq(line, "status") == 1 || Cli_eq(line, "quit") == 1 || Cli_eq(line, "exit") == 1 {
        return 1
    }
    if Cli_starts_with(line, "tab ") == 1 {
        return 1
    }
    if Cli_eq(line, "split h") == 1 || Cli_eq(line, "split v") == 1 {
        return 1
    }
    if Cli_eq(line, "profiles") == 1 || Cli_eq(line, "identities") == 1 || Cli_eq(line, "palette") == 1 || Cli_eq(line, "roadmap") == 1 {
        return 1
    }
    if Cli_eq(line, "ssh") == 1 || Cli_eq(line, "forward") == 1 || Cli_eq(line, "process") == 1 || Cli_eq(line, "fix") == 1 {
        return 1
    }
    if Cli_eq(line, "ext") == 1 || Cli_eq(line, "macro") == 1 || Cli_eq(line, "broadcast") == 1 || Cli_eq(line, "gpu") == 1 || Cli_eq(line, "phases") == 1 {
        return 1
    }
    if Cli_starts_with(line, "explain ") == 1 || Cli_starts_with(line, "search ") == 1 {
        return 1
    }
    if Cli_starts_with(line, "session ") == 1 {
        return 1
    }
    return 0
}

fn Cli_run_shell_mode(app){
    let mut state = app
    let mut shell_ready = 0
    let mut shell = ShellSession_empty()
    ShellIo_welcome()
    while state.running == 1 {
        let line = ShellIo_read_line()
        if Cli_eq(line, "quit") == 1 || Cli_eq(line, "exit") == 1 {
            state = GhostTermApp_stop(state)
            break
        }
        if strlen(line) > 0 {
            if Cli_is_meta_command(line) == 1 {
                state = Cli_dispatch(state, line)
            } else {
                if shell_ready == 0 {
                    shell = ShellSession_spawn(ShellKind.Bash, 1, 1)
                    ShellIo_bootstrap(shell)
                    shell_ready = 1
                }
                ShellIo_exec(shell, line)
            }
        }
    }
    if shell_ready == 1 {
        ShellSession_close(shell)
    }
    print("Goodbye.", color: "#22D3EE")
}

fn Cli_split_token(line, idx){
    let parts = line.split(" ")
    let mut i = 0
    for p in parts {
        if i == idx {
            return p
        }
        i = i + 1
    }
    return ""
}

fn Cli_starts_with(line, prefix){
    return line.starts_with(prefix)
}

fn Cli_help(){
    print("\ncommands:", color: bold)
    print("  help                         Show this help")
    print("  status                       Tab + layout status")
    print("  tab list                     List tabs")
    print("  tab new | private | sandbox  Create tabs")
    print("  tab rename <name>            Rename active tab")
    print("  tab dup                      Duplicate active tab")
    print("  tab pin | tab unpin          Pin / unpin active tab")
    print("  tab lock | tab unlock        Lock / unlock active tab")
    print("  tab close                    Close active tab")
    print("  tab use <id>                 Switch to tab by id")
    print("  split h | split v            Split panes")
    print("  search <query>               Scrollback search")
    print("  session save <name>          Save workspace")
    print("  session restore <name>       Restore workspace")
    print("  ssh | forward | process      Managers (demo)")
    print("  gpu                          GPU window")
    print("  quit                         Exit")
    print("")
    print("  Any other line runs in your shell (pwd, ls, cd, ...)", color: dim)
    print("")
}

fn Cli_dispatch(state, line){
    if Cli_eq(line, "help") == 1 {
        Cli_help()
        return state
    }
    if Cli_eq(line, "status") == 1 {
        GhostTermApp_status(state)
        return state
    }
    if Cli_eq(line, "tab list") == 1 {
        TabManager_print(state.tabs)
        return state
    }
    if Cli_starts_with(line, "tab new") == 1 {
        return GhostTermApp_new_tab(state, "shell", TabKind.Standard)
    }
    if Cli_starts_with(line, "tab private") == 1 {
        return GhostTermApp_new_private_tab(state, "private")
    }
    if Cli_starts_with(line, "tab sandbox") == 1 {
        return GhostTermApp_new_sandbox_tab(state, "sandbox")
    }
    if Cli_starts_with(line, "tab rename ") == 1 {
        let name = Cli_split_token(line, 2)
        return GhostTermApp_rename_active(state, name)
    }
    if Cli_eq(line, "tab dup") == 1 {
        return GhostTermApp_duplicate_active(state)
    }
    if Cli_eq(line, "tab pin") == 1 {
        return GhostTermApp_pin_active(state, 1)
    }
    if Cli_eq(line, "tab unpin") == 1 {
        return GhostTermApp_pin_active(state, 0)
    }
    if Cli_eq(line, "tab lock") == 1 {
        return GhostTermApp_lock_active(state, 1)
    }
    if Cli_eq(line, "tab unlock") == 1 {
        return GhostTermApp_lock_active(state, 0)
    }
    if Cli_eq(line, "tab close") == 1 {
        return GhostTermApp_close_active(state)
    }
    if Cli_starts_with(line, "tab use ") == 1 {
        let id = str_to_i32(Cli_split_token(line, 2))
        return GhostTermApp_switch_tab(state, id)
    }
    if Cli_eq(line, "split h") == 1 {
        return GhostTermApp_split_active(state, SplitDirection.Horizontal)
    }
    if Cli_eq(line, "split v") == 1 {
        return GhostTermApp_split_active(state, SplitDirection.Vertical)
    }
    if Cli_eq(line, "profiles") == 1 {
        ProfileRegistry_print(state.profiles)
        return state
    }
    if Cli_eq(line, "identities") == 1 {
        IdentityRegistry_print(state.identities)
        return state
    }
    if Cli_eq(line, "palette") == 1 {
        CommandPalette_help()
        return state
    }
    if Cli_eq(line, "roadmap") == 1 {
        GhostTermApp_show_roadmap()
        return state
    }
    if Cli_eq(line, "ssh") == 1 {
        SshManager_print(SshManager_seed(SshManager_new()))
        return state
    }
    if Cli_eq(line, "forward") == 1 {
        PortForwardManager_print(PortForwardManager_seed(PortForwardManager_new()))
        return state
    }
    if Cli_eq(line, "process") == 1 {
        ProcessManager_print(ProcessManager_seed(ProcessManager_new()))
        return state
    }
    if Cli_eq(line, "fix") == 1 {
        AiFix_demo()
        return state
    }
    if Cli_eq(line, "ext") == 1 {
        PluginRegistry_list()
        return state
    }
    if Cli_eq(line, "macro") == 1 {
        MacroRecorder_demo()
        return state
    }
    if Cli_eq(line, "broadcast") == 1 {
        BroadcastSession_demo()
        return state
    }
    if Cli_eq(line, "gpu") == 1 {
        Gpu_run_demo_stub()
        return state
    }
    if Cli_eq(line, "phases") == 1 {
        Cli_run_phases()
        return state
    }
    if Cli_starts_with(line, "explain ") == 1 {
        AiExplain_command("find . -name \"*.rs\"")
        return state
    }
    if Cli_starts_with(line, "search ") == 1 {
        let buf = ScrollbackBuffer_new()
        let b2 = ScrollbackBuffer_append(buf, "git commit -m init")
        let b3 = ScrollbackBuffer_append(b2, "cargo build release")
        let b4 = ScrollbackBuffer_append(b3, "npm install")
        ScrollbackBuffer_search_print(b4, "git")
        return state
    }
    if Cli_starts_with(line, "session save") == 1 {
        Session_save(state.tabs, "default")
        return state
    }
    if Cli_starts_with(line, "session restore ") == 1 {
        let name = Cli_split_token(line, 2)
        return Session_restore_app(name)
    }
    if Cli_eq(line, "session list") == 1 {
        Session_list_placeholder()
        return state
    }
    if Cli_eq(line, "quit") == 1 || Cli_eq(line, "exit") == 1 {
        return GhostTermApp_stop(state)
    }
    if strlen(line) > 0 {
        print(`unknown: ${line}`, color: yellow)
    }
    return state
}

fn Cli_run_loop(app){
    let mut state = app
    Cli_help()
    while state.running == 1 {
        let line = input("ghostterm> ")
        state = Cli_dispatch(state, line)
    }
    print("Goodbye.", color: "#22D3EE")
}

fn Cli_run_phases(){
    print("\n========== Phases 2–6 ==========", color: bold)
    Highlight_demo()
    let buf = ScrollbackBuffer_new()
    let b = ScrollbackBuffer_append(buf, "git status")
    ScrollbackBuffer_search_print(b, "git")
    SshManager_print(SshManager_seed(SshManager_new()))
    PortForwardManager_print(PortForwardManager_seed(PortForwardManager_new()))
    ProcessManager_print(ProcessManager_seed(ProcessManager_new()))
    AiExplain_demo()
    AiFix_demo()
    PluginRegistry_list()
    MacroRecorder_demo()
    BroadcastSession_demo()
    print("\nPhase 2 GPU: set GHOSTTERM_GPU=1 nyra run .", color: cyan)
}

fn Cli_run_showcase(){
    print("\n--- showcase (phases 1–6) ---", color: bold)
    let mut state = GhostTermApp_new()
    state = Cli_dispatch(state, "tab new")
    state = Cli_dispatch(state, "tab private")
    GhostTermApp_status(state)
    Cli_run_phases()
    Session_save(state.tabs, "default")
    print("\nModes:", color: dim)
    print("  GHOSTTERM_GPU=1 nyra run .       → GPU + PTY window", color: dim)
    print("  GHOSTTERM_REPL=1 nyra run .      → interactive REPL", color: dim)
}

fn Cli_run(){
    print_ghostterm_banner()
    if env_has("GHOSTTERM_GPU") == 1 {
        Gpu_run_interactive_stub()
        return
    }
    if env_has("GHOSTTERM_REPL") == 1 {
        Cli_run_loop(GhostTermApp_new())
        return
    }
    if env_has("GHOSTTERM_SHOWCASE") == 1 {
        Cli_run_showcase()
        return
    }
    Cli_run_shell_mode(GhostTermApp_new())
}
