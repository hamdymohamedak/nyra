use std::path::PathBuf;

/// Search roots for `import "sonic/..."`.
pub fn sonic_roots() -> Vec<PathBuf> {
    let mut roots = Vec::new();
    let mut push_unique = |p: PathBuf| {
        if p.is_dir() && !roots.iter().any(|r| r == &p) {
            roots.push(p);
        }
    };

    if let Ok(cwd) = std::env::current_dir() {
        let mut dir = cwd;
        for _ in 0..12 {
            let p = dir.join("sonic");
            if p.join("core/microservice.ny").is_file() {
                push_unique(p);
                break;
            }
            if !dir.pop() {
                break;
            }
        }
    }
    let dev = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("../../sonic");
    if dev.join("core/microservice.ny").is_file() {
        push_unique(dev);
    }
    if let Ok(home) = std::env::var("NYRA_HOME") {
        if !home.is_empty() {
            let p = PathBuf::from(home).join("share/sonic");
            if p.join("core/microservice.ny").is_file() {
                push_unique(p);
            }
        }
    }
    roots
}

fn sonic_candidates(rest: &str) -> Vec<String> {
    let mut out = Vec::new();
    if rest.ends_with(".ny") || rest.ends_with(".nyra") {
        out.push(rest.to_string());
    } else {
        out.push(format!("{rest}.ny"));
        out.push(format!("{rest}/mod.ny"));
    }
    out
}

pub fn resolve_sonic_import(import_path: &str) -> Option<PathBuf> {
    let rest = import_path.strip_prefix("sonic/")?;
    for root in sonic_roots() {
        for candidate in sonic_candidates(rest) {
            let p = root.join(&candidate);
            if p.is_file() {
                return Some(p);
            }
        }
    }
    None
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn resolves_sonic_microservice() {
        let p = resolve_sonic_import("sonic/core/microservice.ny");
        assert!(p.is_some(), "sonic/core/microservice.ny should resolve in dev tree");
    }
}
