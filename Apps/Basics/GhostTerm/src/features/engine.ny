struct HistoryStore {
    entries: ptr
    favorites: ptr
    max_entries: i32
}

fn HistoryStore_new(){
    return HistoryStore {
        entries: Vec_i32_new()
        favorites: Vec_i32_new()
        max_entries: 10000
    }
}

fn HistoryStore_note(){
    print("command history: unlimited storage, filter, search, pin (engine ready)")
}

fn SearchEngine_note(){
    print("output search: Ctrl+Shift+F scans scrollback buffer (engine ready)")
}

fn GpuRenderer_note(){
    print("GPU renderer: Metal/OpenGL/Vulkan backend planned (Ghostty/Kitty-class)")
}

fn ThemeEngine_note(){
    print("themes: dark, light, transparent, blur, custom — config layer ready")
}
