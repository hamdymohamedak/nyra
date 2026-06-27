use std::path::PathBuf;
use std::process::Command;

use serde::Deserialize;

use crate::semver::{self, Req, Version};

#[derive(Debug, Clone, Deserialize)]
pub struct RegistryPackage {
    pub name: String,
    pub version: String,
    pub git_url: String,
    #[serde(default = "default_git_rev")]
    pub git_rev: String,
}

fn default_git_rev() -> String {
    "main".into()
}

const DEFAULT_REGISTRY: &str = "http://127.0.0.1:9470";

pub fn default_registry_url() -> String {
    if let Some(home) = dirs::home_dir() {
        let config = home.join(".nyra/config");
        if let Ok(text) = std::fs::read_to_string(&config) {
            for line in text.lines() {
                let line = line.trim();
                if let Some(rest) = line.strip_prefix("registry=") {
                    let url = rest.trim();
                    if !url.is_empty() {
                        return url.to_string();
                    }
                }
            }
        }
    }
    DEFAULT_REGISTRY.to_string()
}

pub fn http_get(url: &str) -> Result<String, String> {
    if let Some(path) = url.strip_prefix("file://") {
        return std::fs::read_to_string(path).map_err(|e| format!("read {path}: {e}"));
    }
    let output = Command::new("curl")
        .args(["-sf", url])
        .output()
        .map_err(|e| format!("curl failed: {e}"))?;
    if !output.status.success() {
        return Err(format!("HTTP GET failed: {url}"));
    }
    String::from_utf8(output.stdout).map_err(|e| e.to_string())
}

pub fn list_packages(registry: &str) -> Result<Vec<RegistryPackage>, String> {
    let body = http_get(&format!("{registry}/index"))?;
    serde_json::from_str(&body).map_err(|e| format!("invalid registry index: {e}"))
}

pub fn list_package_versions(registry: &str, name: &str) -> Result<Vec<RegistryPackage>, String> {
    let body = http_get(&format!("{registry}/index/{name}"))?;
    serde_json::from_str(&body).map_err(|e| format!("invalid registry versions for {name}: {e}"))
}

pub fn resolve_from_registry(
    registry: &str,
    name: &str,
    req: Option<&Req>,
) -> Result<RegistryPackage, String> {
    let versions = list_package_versions(registry, name)?;
    if versions.is_empty() {
        return Err(format!("package '{name}' not found in registry {registry}"));
    }
    let parsed: Vec<Version> = versions
        .iter()
        .map(|p| semver::parse_version(&p.version))
        .collect::<Result<Vec<_>, _>>()?;
    let chosen = if let Some(req) = req {
        let best = semver::best_match(req, parsed.iter())
            .ok_or_else(|| format!("no version of '{name}' satisfies requirement"))?;
        versions
            .into_iter()
            .find(|p| semver::parse_version(&p.version).ok().as_ref() == Some(&best))
            .ok_or_else(|| format!("registry index inconsistent for '{name}'"))?
    } else {
        let mut sorted = versions;
        sorted.sort_by(|a, b| {
            let va = semver::parse_version(&a.version).unwrap_or(Version {
                major: 0,
                minor: 0,
                patch: 0,
            });
            let vb = semver::parse_version(&b.version).unwrap_or(Version {
                major: 0,
                minor: 0,
                patch: 0,
            });
            va.compare(&vb)
        });
        sorted.pop().expect("non-empty")
    };
    Ok(chosen)
}

pub fn registry_data_dir() -> PathBuf {
    dirs::home_dir()
        .unwrap_or_else(|| PathBuf::from("."))
        .join(".nyra/registry")
}
