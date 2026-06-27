//! Locate dependency sources via `cargo fetch` + `cargo metadata`.

use std::path::{Path, PathBuf};
use std::process::Command;

use serde_json::Value;

/// Write a scratch manifest, fetch deps, return the crate source root.
pub fn fetch_dependency_root(
    wrapper_dir: &Path,
    crate_name: &str,
    version: &str,
) -> Result<PathBuf, String> {
    std::fs::create_dir_all(wrapper_dir.join("src")).map_err(|e| e.to_string())?;
    std::fs::write(wrapper_dir.join("src/lib.rs"), "// fetch stub\n").map_err(|e| e.to_string())?;
    let dep_line = format!("{crate_name} = \"{version}\"");
    let cargo_toml = format!(
        r#"[package]
name = "nyra-bindgen-fetch"
version = "0.1.0"
edition = "2021"
publish = false

[workspace]

[dependencies]
{dep_line}
"#
    );
    std::fs::write(wrapper_dir.join("Cargo.toml"), cargo_toml).map_err(|e| e.to_string())?;

    let status = Command::new("cargo")
        .arg("fetch")
        .arg("--manifest-path")
        .arg(wrapper_dir.join("Cargo.toml"))
        .status()
        .map_err(|e| format!("cargo fetch failed: {e}"))?;
    if !status.success() {
        return Err(format!("cargo fetch failed for {crate_name} {version}"));
    }

    let output = Command::new("cargo")
        .arg("metadata")
        .arg("--manifest-path")
        .arg(wrapper_dir.join("Cargo.toml"))
        .arg("--format-version")
        .arg("1")
        .arg("--no-deps")
        .output()
        .map_err(|e| format!("cargo metadata failed: {e}"))?;
    if !output.status.success() {
        return Err("cargo metadata failed".into());
    }
    let meta: Value = serde_json::from_slice(&output.stdout).map_err(|e| e.to_string())?;

    let packages = meta["packages"]
        .as_array()
        .ok_or("metadata missing packages")?;

    for pkg in packages {
        let name = pkg["name"].as_str().unwrap_or("");
        if name == crate_name {
            let manifest = pkg["manifest_path"]
                .as_str()
                .ok_or("missing manifest_path")?;
            let root = PathBuf::from(manifest)
                .parent()
                .ok_or("invalid manifest_path")?
                .to_path_buf();
            return Ok(root);
        }
    }

    // With --no-deps we only get our stub; run full metadata.
    let output = Command::new("cargo")
        .arg("metadata")
        .arg("--manifest-path")
        .arg(wrapper_dir.join("Cargo.toml"))
        .arg("--format-version")
        .arg("1")
        .output()
        .map_err(|e| format!("cargo metadata failed: {e}"))?;
    let meta: Value = serde_json::from_slice(&output.stdout).map_err(|e| e.to_string())?;
    for pkg in meta["packages"].as_array().unwrap_or(&vec![]) {
        if pkg["name"].as_str() == Some(crate_name) {
            let manifest = pkg["manifest_path"].as_str().unwrap();
            return Ok(PathBuf::from(manifest)
                .parent()
                .unwrap()
                .to_path_buf());
        }
    }

    Err(format!("could not locate source for crate '{crate_name}'"))
}
