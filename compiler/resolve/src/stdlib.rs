use std::path::{Path, PathBuf};

fn push_unique_root(roots: &mut Vec<PathBuf>, p: PathBuf) {
    if p.is_dir() && !roots.iter().any(|r| r == &p) {
        roots.push(p);
    }
}

fn walk_stdlib_roots_from(start: &Path, roots: &mut Vec<PathBuf>) {
    let mut dir = if start.is_file() {
        start.parent().unwrap_or(start).to_path_buf()
    } else {
        start.to_path_buf()
    };
    for _ in 0..24 {
        let p = dir.join("stdlib");
        if p.join("vec.ny").is_file() {
            push_unique_root(roots, p);
            break;
        }
        if !dir.pop() {
            break;
        }
    }
}

/// Search roots for `import "stdlib/..."` and `import "std/..."`.
/// Workspace and dev-tree stdlib take precedence over NYRA_HOME so repo sources win during development.
pub fn stdlib_roots() -> Vec<PathBuf> {
    stdlib_roots_near(None)
}

pub fn stdlib_roots_near(near: Option<&Path>) -> Vec<PathBuf> {
    let mut roots = Vec::new();

    if let Some(start) = near {
        walk_stdlib_roots_from(start, &mut roots);
    }

    if let Ok(cwd) = std::env::current_dir() {
        walk_stdlib_roots_from(&cwd, &mut roots);
    }
    let dev = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("../../stdlib");
    if dev.join("vec.ny").is_file() {
        push_unique_root(&mut roots, dev);
    }
    if let Ok(home) = std::env::var("NYRA_HOME") {
        if !home.is_empty() {
            push_unique_root(&mut roots, PathBuf::from(home).join("share/stdlib"));
        }
    }
    if let Ok(exe) = std::env::current_exe() {
        if let Some(bin) = exe.parent() {
            if let Some(install_root) = bin.parent() {
                push_unique_root(&mut roots, install_root.join("share/stdlib"));
            }
        }
    }
    roots
}

fn stdlib_candidates(rest: &str) -> Vec<String> {
    let mut out = Vec::new();
    if rest.ends_with(".ny") || rest.ends_with(".nyra") {
        out.push(rest.to_string());
    } else {
        out.push(format!("{rest}.ny"));
        out.push(format!("{rest}/mod.ny"));
    }
    out
}

pub fn resolve_stdlib_import(import_path: &str) -> Option<PathBuf> {
    resolve_stdlib_import_near(import_path, None)
}

pub fn resolve_stdlib_import_near(import_path: &str, near: Option<&Path>) -> Option<PathBuf> {
    let rest = import_path
        .strip_prefix("stdlib/")
        .or_else(|| import_path.strip_prefix("std/"))?;
    for root in stdlib_roots_near(near) {
        for candidate in stdlib_candidates(rest) {
            let p = root.join(&candidate);
            if p.is_file() {
                return Some(p);
            }
        }
    }
    None
}

/// All `.ny` sources under the primary stdlib root (auto-prelude).
/// Excludes `prelude.ny` (legacy bundle) and non-Nyra trees like `rt/`.
pub fn collect_stdlib_sources() -> Vec<PathBuf> {
    collect_stdlib_sources_near(None)
}

pub fn collect_stdlib_sources_near(near: Option<&Path>) -> Vec<PathBuf> {
    let Some(root) = stdlib_roots_near(near)
        .into_iter()
        .find(|r| r.join("vec.ny").is_file())
    else {
        return Vec::new();
    };
    let mut files = Vec::new();
    collect_ny_sources(&root, &root, &mut files);
    files.sort();
    files.dedup();
    files
}

fn collect_ny_sources(root: &Path, dir: &Path, out: &mut Vec<PathBuf>) {
    let entries = match std::fs::read_dir(dir) {
        Ok(e) => e,
        Err(_) => return,
    };
    for entry in entries.flatten() {
        let path = entry.path();
        if path.is_dir() {
            let name = path.file_name().and_then(|n| n.to_str()).unwrap_or("");
            if name == "rt" || name == "rt_wasi" || name == "core" {
                continue;
            }
            collect_ny_sources(root, &path, out);
        } else if path.extension().and_then(|e| e.to_str()) == Some("ny") {
            if path.file_name().and_then(|n| n.to_str()) == Some("prelude.ny") {
                continue;
            }
            out.push(path);
        }
    }
}

pub fn resolve_pkg_import(base_dir: &Path, import_path: &str) -> Option<PathBuf> {
    let rest = import_path.strip_prefix("pkg/")?;
    let root = super::project_root_for(base_dir);
    let cache = root.join(".nyra/cache").join(rest);
    if !cache.is_dir() {
        return None;
    }
    for candidate in pkg_entry_candidates(rest) {
        let p = cache.join(&candidate);
        if p.is_file() {
            return Some(p);
        }
    }
    if let Ok(entries) = std::fs::read_dir(&cache) {
        for entry in entries.flatten() {
            let p = entry.path();
            if p.extension().and_then(|e| e.to_str()) == Some("ny") {
                let name = p.file_name().and_then(|n| n.to_str()).unwrap_or("");
                if name != "main.ny" {
                    return Some(p);
                }
            }
        }
    }
    None
}

fn pkg_entry_candidates(rest: &str) -> Vec<String> {
    let mut out = stdlib_candidates(rest);
    out.push(format!("{rest}.ny"));
    out.push("sqlite.ny".to_string());
    out.push("serde.ny".to_string());
    out.push("toml.ny".to_string());
    out.push("mod.ny".to_string());
    for name in crate::paths::MAIN_ENTRY_NAMES {
        out.push(name.to_string());
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn dev_stdlib_root_exists() {
        let roots = stdlib_roots();
        assert!(
            roots.iter().any(|r| r.join("vec.ny").is_file()),
            "expected repo stdlib root in {:?}",
            roots
        );
    }

    #[test]
    fn resolves_std_vec() {
        let p = resolve_stdlib_import("stdlib/vec.ny").expect("stdlib/vec.ny");
        assert!(p.ends_with("vec.ny"));
    }

    #[test]
    fn resolves_std_alias_without_extension() {
        let p = resolve_stdlib_import("std/json/mod").expect("std/json/mod");
        assert!(p.ends_with("json/mod.ny"));
    }

    #[test]
    fn collect_stdlib_sources_includes_vec() {
        let files = collect_stdlib_sources();
        assert!(
            files.iter().any(|p| p.file_name().and_then(|n| n.to_str()) == Some("vec.ny")),
            "expected vec.ny in prelude sources: {:?}",
            files.len()
        );
        assert!(
            !files.iter().any(|p| p.file_name().and_then(|n| n.to_str()) == Some("prelude.ny")),
            "prelude.ny must not be auto-loaded"
        );
    }

    #[test]
    fn stdlib_roots_from_entry_path_without_cwd() {
        let repo = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("../..");
        let entry = repo.join("tests/conformance/pass/types/bool.ny");
        assert!(entry.is_file(), "missing {}", entry.display());
        let roots = stdlib_roots_near(Some(&entry));
        assert!(
            roots.iter().any(|r| r.join("testing.ny").is_file()),
            "expected testing.ny via entry-path stdlib roots: {:?}",
            roots
        );
    }
}
