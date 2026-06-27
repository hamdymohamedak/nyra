use std::fs;
use std::path::{Path, PathBuf};

use crate::registry_client::{default_registry_url, resolve_from_registry};
use crate::semver::{self, Req};

#[derive(Debug, Clone)]
pub struct PackageSpec {
    pub name: &'static str,
    pub version: &'static str,
    pub git_url: Option<&'static str>,
    pub git_rev: &'static str,
    /// Relative to Nyra repo root (dev fallback when git is unavailable).
    pub local_subpath: Option<&'static str>,
}

pub fn known_packages() -> &'static [PackageSpec] {
    &[
        PackageSpec {
            name: "ny-sqlite",
            version: "0.1.0",
            git_url: None,
            git_rev: "main",
            local_subpath: Some("examples/packages/ny-sqlite"),
        },
        PackageSpec {
            name: "ny-serde",
            version: "0.1.0",
            git_url: None,
            git_rev: "main",
            local_subpath: Some("examples/packages/ny-serde"),
        },
        PackageSpec {
            name: "ny-toml",
            version: "0.1.0",
            git_url: None,
            git_rev: "main",
            local_subpath: Some("examples/packages/ny-toml"),
        },
        PackageSpec {
            name: "ny-crypto",
            version: "0.1.0",
            git_url: None,
            git_rev: "main",
            local_subpath: None,
        },
        PackageSpec {
            name: "ny-websocket",
            version: "0.1.0",
            git_url: None,
            git_rev: "main",
            local_subpath: None,
        },
    ]
}

pub fn resolve_package_name(name: &str) -> Option<&'static PackageSpec> {
    known_packages().iter().find(|p| p.name == name)
}

pub fn repo_root() -> Option<PathBuf> {
    if let Ok(cwd) = std::env::current_dir() {
        let mut dir = cwd;
        for _ in 0..12 {
            if dir.join("stdlib").join("vec.ny").is_file() {
                return Some(dir);
            }
            if !dir.pop() {
                break;
            }
        }
    }
    let dev = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("..");
    if dev.join("stdlib").join("vec.ny").is_file() {
        return Some(dev);
    }
    None
}

fn copy_dir_all(src: &Path, dst: &Path) -> Result<(), String> {
    fs::create_dir_all(dst).map_err(|e| e.to_string())?;
    for entry in fs::read_dir(src).map_err(|e| e.to_string())? {
        let entry = entry.map_err(|e| e.to_string())?;
        let ty = entry.file_type().map_err(|e| e.to_string())?;
        let to = dst.join(entry.file_name());
        if ty.is_dir() {
            copy_dir_all(&entry.path(), &to)?;
        } else {
            fs::copy(entry.path(), &to).map_err(|e| e.to_string())?;
        }
    }
    Ok(())
}

/// Split `name@^1.0.0` into (`name`, optional version requirement).
pub fn split_name_and_req(spec: &str) -> (&str, Option<Req>) {
    if let Some((name, ver)) = spec.split_once('@') {
        let req = semver::parse_req(ver).ok();
        (name.trim(), req)
    } else {
        (spec.trim(), None)
    }
}

pub fn fetch_package(name: &str, dest: &Path) -> Result<(), String> {
    fetch_package_versioned(name, dest, None)
}

pub fn fetch_package_versioned(
    name: &str,
    dest: &Path,
    version_req: Option<&Req>,
) -> Result<(), String> {
    if dest.exists() && dest.join("nyra.mod").is_file() {
        return Ok(());
    }

    let (base_name, inline_req) = split_name_and_req(name);
    let req = version_req.or(inline_req.as_ref());

    if base_name.starts_with("https://") || base_name.starts_with("git@") {
        return crate::fetch_git(base_name, "main", dest);
    }

    if let Some(spec) = resolve_package_name(base_name) {
        if let Some(sub) = spec.local_subpath {
            if let Some(root) = repo_root() {
                let src = root.join(sub);
                if src.is_dir() {
                    if dest.exists() {
                        fs::remove_dir_all(dest).map_err(|e| e.to_string())?;
                    }
                    copy_dir_all(&src, dest)?;
                    return Ok(());
                }
            }
        }
    }

    if let Ok(pkg) = resolve_from_registry(&default_registry_url(), base_name, req) {
        if !pkg.git_url.is_empty() {
            return crate::fetch_git(&pkg.git_url, &pkg.git_rev, dest);
        }
    }

    if let Some(spec) = resolve_package_name(base_name) {
        if let Some(url) = spec.git_url {
            return crate::fetch_git(url, spec.git_rev, dest);
        }
        return Err(format!(
            "package '{base_name}' is known but has no local copy or git URL"
        ));
    }

    Err(format!(
        "unknown package '{base_name}' — try `nyra pkg install name@^1.0.0`, a git URL, or see docs/nyrapkg-v1.md"
    ))
}

pub fn resolved_version_for_package(name: &str, version_req: Option<&Req>) -> String {
    let (base_name, inline_req) = split_name_and_req(name);
    let req = version_req.or(inline_req.as_ref());
    if let Ok(pkg) = resolve_from_registry(&default_registry_url(), base_name, req) {
        return pkg.version;
    }
    if let Some(spec) = resolve_package_name(base_name) {
        if let Some(req) = req {
            if let Ok(ver) = semver::parse_version(spec.version) {
                if semver::satisfies(req, &ver) {
                    return spec.version.to_string();
                }
            }
        } else {
            return spec.version.to_string();
        }
    }
    "0.0.0".into()
}
