//! C header → Nyra FFI bindings via libclang.

mod config;
mod emit;
mod names;
mod parse;
mod shim;
mod types;

pub use config::BindConfig;
pub use emit::GeneratedCBindings;
pub use types::NyraType;

use std::path::Path;

/// Parse a C header and emit Nyra `extern fn` bindings + `nyra.mod` link hints.
pub fn bind_header(config: &BindConfig) -> Result<GeneratedCBindings, String> {
    let spec = parse::parse_header(config)?;
    emit::generate_bindings(config, &spec)
}

/// Convenience: bind and write default output paths under `project_root`.
pub fn bind_header_to_project(config: &BindConfig, project_root: &Path) -> Result<GeneratedCBindings, String> {
    let gen = bind_header(config)?;
    let out = config
        .output
        .clone()
        .unwrap_or_else(|| default_output_path(project_root, &config.header));
    if let Some(parent) = out.parent() {
        std::fs::create_dir_all(parent).map_err(|e| e.to_string())?;
    }
    std::fs::write(&out, &gen.bindings_ny).map_err(|e| e.to_string())?;

    if let Some(ref shim) = gen.shim_c {
        let shim_path = project_root.join(config.shim_source_path());
        if let Some(parent) = shim_path.parent() {
            std::fs::create_dir_all(parent).map_err(|e| e.to_string())?;
        }
        std::fs::write(&shim_path, shim).map_err(|e| e.to_string())?;
    }

    if config.update_mod {
        update_nyra_mod(project_root, &gen.mod_lines)?;
    }
    Ok(gen)
}

fn default_output_path(project_root: &Path, header: &Path) -> std::path::PathBuf {
    let stem = header
        .file_stem()
        .map(|s| s.to_string_lossy().into_owned())
        .unwrap_or_else(|| "bindings".into());
    project_root.join(format!("vendor/bindings/{stem}.ny"))
}

fn update_nyra_mod(project_root: &Path, lines: &[String]) -> Result<(), String> {
    let mod_path = project_root.join("nyra.mod");
    let mut existing = if mod_path.is_file() {
        std::fs::read_to_string(&mod_path).map_err(|e| e.to_string())?
    } else {
        String::from("module example.local\n\n")
    };
    for line in lines {
        if existing.lines().any(|l| l.trim() == line.trim()) {
            continue;
        }
        if !existing.ends_with('\n') {
            existing.push('\n');
        }
        existing.push_str(line);
        existing.push('\n');
    }
    std::fs::write(&mod_path, existing).map_err(|e| e.to_string())
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::path::PathBuf;

    fn fixture(name: &str) -> PathBuf {
        PathBuf::from(env!("CARGO_MANIFEST_DIR"))
            .join("tests/fixtures")
            .join(name)
    }

    fn base_config(header: PathBuf) -> BindConfig {
        BindConfig {
            header,
            includes: vec![],
            defines: vec![],
            link_libs: vec!["m".into()],
            function_prefix: None,
            export_filter: vec![],
            output: None,
            update_mod: false,
            generate_shims: true,
        }
    }

    #[test]
    fn binds_fixtures() {
        if std::env::var("NYRA_SKIP_LIBCLANG").is_ok() {
            return;
        }
        let minimal = bind_header(&base_config(fixture("minimal.h"))).expect("minimal");
        assert!(minimal.bindings_ny.contains("extern fn add("));
        assert!(minimal.bindings_ny.contains("extern fn greet("));
        assert!(minimal.functions >= 2);

        let structs = bind_header(&base_config(fixture("struct.h"))).expect("struct");
        assert!(structs.bindings_ny.contains("struct Point repr(C)"));
        assert!(structs.bindings_ny.contains("x: i32"));
        assert!(structs.bindings_ny.contains("extern fn point_sum("));

        let cb = bind_header(&base_config(fixture("callback.h"))).expect("callback");
        assert!(cb.shims >= 1);
        assert!(cb.bindings_ny.contains("nyra_shim_"));
        assert!(cb.shim_c.as_ref().unwrap().contains("nyra_shim_"));

        let nested = bind_header(&base_config(fixture("nested_struct.h"))).expect("nested");
        assert!(nested.bindings_ny.contains("struct Inner repr(C)"));
        assert!(nested.bindings_ny.contains("struct Outer repr(C)"));
        assert!(nested.bindings_ny.contains("inner: Inner"));
        assert!(nested.bindings_ny.contains("extern fn make_outer("));

        let kw = bind_header(&base_config(fixture("keywords.h"))).expect("keywords");
        assert!(kw.bindings_ny.contains("in_: ptr"));
        assert!(kw.bindings_ny.contains("out_: ptr"));
    }
}
