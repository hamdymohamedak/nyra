
fn CommandPalette_help(){
    print("GhostTerm command palette (Ctrl+Shift+P)", color: cyan)
    print("  tab:new              Create tab")
    print("  tab:rename           Rename active tab")
    print("  tab:duplicate        Duplicate tab")
    print("  tab:pin              Pin tab")
    print("  tab:lock             Lock tab")
    print("  layout:split-h       Horizontal split")
    print("  layout:split-v       Vertical split")
    print("  session:save         Save workspace session")
    print("  session:restore      Restore last session")
    print("  search:output        Search terminal output")
    print("  identity:switch      Switch identity profile")
    print("  theme:toggle         Toggle dark/light")
    print("  gpu:toggle           Toggle GPU renderer")
}

fn CommandPalette_dispatch(cmd){
    if cmd == "palette" {
        CommandPalette_help()
        return 1
    }
    return 0
}
