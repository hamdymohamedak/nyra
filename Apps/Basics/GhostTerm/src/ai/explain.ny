extern fn strlen(s: string) -> i32

fn AiExplain_command(cmd){
    print("\n--- AI Explain ---", color: cyan)
    if cmd.starts_with("find ") == 1 {
        print("find — search files recursively from current directory")
        print("  -name \"*.rs\"  → match files ending in .rs")
        return
    }
    if cmd.starts_with("git ") == 1 {
        print("git — version control command")
        print("  common: commit, push, pull, checkout, cherry-pick")
        return
    }
    if cmd.starts_with("cargo ") == 1 {
        print("cargo — Rust build tool")
        print("  build → compile  run → compile + execute  test → run tests")
        return
    }
    print(`explain: ${cmd}`)
    print("(connect LLM via stdlib/bridge for full explanations)")
}

fn AiExplain_demo(){
    AiExplain_command("find . -name \"*.rs\"")
}
