struct PluginManifest {
    id: string
    name: string
    version: string
    enabled: i32
}

fn PluginRegistry_list(){
    print("extensions (VS Code-style plugins):", color: bold)
    print("  [builtin] syntax-highlight  v0.1  enabled")
    print("  [builtin] scrollback-search v0.1  enabled")
    print("  [stub]    docker-tools       v0.0  install via nyra pkg")
    print("  command: ext list | ext enable <id>")
}

fn PluginRegistry_enable(id){
    print(`extension "${id}" enabled`, color: green)
}
