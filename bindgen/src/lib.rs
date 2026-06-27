//! Syn-based Rust crate bindgen: scan public API → C-ABI wrapper + Nyra `.ny` stubs.

mod emit;
mod fetch;
mod scan;
mod types;

pub use emit::{GeneratedBridge, generate_bridge};
pub use fetch::fetch_dependency_root;
pub use scan::{BindSpec, scan_crate_api};
pub use types::TypeMapper;

use std::path::Path;

/// Full bindgen pipeline for a crates.io dependency.
pub fn bindgen_crate(
    crate_name: &str,
    version: &str,
    wrapper_dir: &Path,
    export_filter: Option<&[String]>,
) -> Result<GeneratedBridge, String> {
    let crate_root = fetch_dependency_root(wrapper_dir, crate_name, version)?;
    let spec = scan_crate_api(&crate_root, crate_name, export_filter)?;
    if spec.items.is_empty() {
        return Err(format!(
            "bindgen: no bindable public API found in crate '{crate_name}'"
        ));
    }
    generate_bridge(crate_name, version, &spec)
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::path::PathBuf;

    #[test]
    fn scan_regex_crate_finds_new_and_is_match() {
        let root = find_regex_src();
        let spec = scan_crate_api(
            &root,
            "regex",
            Some(&["Regex::new".into(), "Regex::is_match".into()]),
        )
        .expect("scan regex");
        assert!(spec.items.iter().any(|i| {
            i.fn_name == "new" && i.owner.as_deref() == Some("Regex")
        }));
        assert!(
            spec.items.iter().any(|i| {
                i.fn_name == "is_match" && i.owner.as_deref() == Some("Regex")
            }),
            "bound items: {:?}",
            spec.items
                .iter()
                .map(|i| format!("{:?}::{}", i.owner, i.fn_name))
                .collect::<Vec<_>>()
        );
        assert!(!spec
            .items
            .iter()
            .any(|i| i.owner.as_deref() == Some("RegexSet")));
    }

    #[test]
    fn bindgen_emits_wrapper_for_regex_new() {
        let gen = regex_bridge();
        assert!(gen.wrapper_rs.contains("regex_Regex_new"));
        assert!(gen.bindings_ny.contains("fn Regex_new"));
    }

    #[test]
    fn regex_fixture_bindings_match_stubs() {
        let gen = regex_bridge();
        let fixture_path = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
            .join("../examples/rust-bridge/regex/stubs/regex/bindings.ny");
        let fixture = std::fs::read_to_string(&fixture_path).expect("read regex bindings stub");
        let expected = fixture
            .lines()
            .skip_while(|line| !line.starts_with("// Auto-generated"))
            .collect::<Vec<_>>()
            .join("\n");
        assert_eq!(
            gen.bindings_ny.trim(),
            expected.trim(),
            "bindings.ny stub is stale — regenerate from bindgen output and update examples/rust-bridge/regex/stubs/regex/bindings.ny"
        );
    }

    fn regex_bridge() -> GeneratedBridge {
        let root = find_regex_src();
        let spec = scan_crate_api(
            &root,
            "regex",
            Some(&["Regex::new".into(), "Regex::is_match".into()]),
        )
        .expect("scan regex");
        generate_bridge("regex", "1.12.0", &spec).expect("generate regex bridge")
    }

    fn find_regex_src() -> PathBuf {
        let home = std::env::var("HOME").unwrap_or_else(|_| "/tmp".into());
        let registry = PathBuf::from(home).join(".cargo/registry/src");
        find_crate_dir(&registry, "regex").unwrap_or_else(|| {
            panic!(
                "regex crate source not found under {} — run `cargo fetch` first",
                registry.display()
            )
        })
    }

    fn find_crate_dir(dir: &Path, crate_name: &str) -> Option<PathBuf> {
        if !dir.is_dir() {
            return None;
        }
        let prefix = format!("{crate_name}-");
        let mut best: Option<(PathBuf, (u64, u64, u64))> = None;
        for entry in std::fs::read_dir(dir).ok()? {
            let entry = entry.ok()?;
            let path = entry.path();
            if !path.is_dir() {
                continue;
            }
            let name = path.file_name()?.to_str()?;
            if let Some(ver_str) = name.strip_prefix(&prefix) {
                let key = parse_dir_version(ver_str);
                if best.as_ref().map(|(_, k)| key > *k).unwrap_or(true) {
                    best = Some((path, key));
                }
            } else if let Some(found) = find_crate_dir(&path, crate_name) {
                let name = found.file_name()?.to_str()?;
                let ver_str = name.strip_prefix(&prefix)?;
                let key = parse_dir_version(ver_str);
                if best.as_ref().map(|(_, k)| key > *k).unwrap_or(true) {
                    best = Some((found, key));
                }
            }
        }
        best.map(|(p, _)| p)
    }

    fn parse_dir_version(ver: &str) -> (u64, u64, u64) {
        let core = ver.split('-').next().unwrap_or(ver);
        let mut parts = core.split('.');
        (
            parts.next().and_then(|p| p.parse().ok()).unwrap_or(0),
            parts.next().and_then(|p| p.parse().ok()).unwrap_or(0),
            parts.next().and_then(|p| p.parse().ok()).unwrap_or(0),
        )
    }
}

