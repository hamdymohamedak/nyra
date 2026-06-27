fn AiFix_build_error(output){
    print("\n--- AI Fix ---", color: cyan)
    if output.contains("cannot find") == 1 {
        print("suggestion: run `cargo build` to refresh deps, or add missing import")
        return
    }
    if output.contains("E0425") == 1 || output.contains("not found") == 1 {
        print("suggestion: check symbol name spelling and scope")
        return
    }
    if output.contains("permission denied") == 1 {
        print("suggestion: chmod +x script or run with appropriate permissions")
        return
    }
    print("no known pattern — paste full error for LLM analysis")
    print("(wire stdlib/bridge Python worker for GPT/Claude fix suggestions)")
}

fn AiFix_demo(){
    AiFix_build_error("error: cannot find crate `serde` in dependencies")
}
