//! Legacy entry: manifest-based ABI symbol presence (see abi_manifest.rs).

fn collect_rt_c_sources(dir: &std::path::Path, out: &mut Vec<std::path::PathBuf>) {
    for entry in std::fs::read_dir(dir).unwrap_or_else(|e| panic!("read {}: {e}", dir.display())) {
        let entry = entry.expect("read_dir entry");
        let path = entry.path();
        if path.is_dir() {
            collect_rt_c_sources(&path, out);
        } else if path.extension().is_some_and(|ext| ext == "c") {
            out.push(path);
        }
    }
}

#[test]
fn nyra_rt_modules_declare_manifest_symbols() {
    // Delegates to the same manifest loader used by abi_manifest.rs tests.
    let path = std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join("../../docs/abi-manifest.toml");
    let text = std::fs::read_to_string(&path).expect("abi-manifest.toml");
    let manifest: toml::Value = toml::from_str(&text).expect("parse manifest");
    let symbols = manifest
        .get("symbol")
        .and_then(|v| v.as_array())
        .expect("symbol array");
    let rt_dir = std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join("../../stdlib/rt");
    let mut combined = String::new();
    let mut modules = Vec::new();
    collect_rt_c_sources(&rt_dir, &mut modules);
    modules.sort();
    for path in modules {
        combined.push_str(
            &std::fs::read_to_string(&path)
                .unwrap_or_else(|e| panic!("read {}: {e}", path.display())),
        );
    }
    for entry in symbols {
        let name = entry
            .get("name")
            .and_then(|v| v.as_str())
            .expect("symbol name");
        assert!(combined.contains(name), "missing {name} in stdlib/rt/*.c");
    }
}
