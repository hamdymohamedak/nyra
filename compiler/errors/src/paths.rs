use std::path::{Path, PathBuf};
use std::sync::Mutex;

static DIAG_ROOT: Mutex<Option<PathBuf>> = Mutex::new(None);

/// Prefer relative paths in diagnostics from this project root.
pub fn set_diagnostic_root(root: impl AsRef<Path>) {
    if let Ok(mut guard) = DIAG_ROOT.lock() {
        *guard = Some(root.as_ref().to_path_buf());
    }
}

pub fn clear_diagnostic_root() {
    if let Ok(mut guard) = DIAG_ROOT.lock() {
        *guard = None;
    }
}

pub fn display_path(file: &str) -> String {
    if file.is_empty() {
        return "<source>".to_string();
    }
    let path = Path::new(file);
    if let Ok(guard) = DIAG_ROOT.lock() {
        if let Some(root) = guard.as_ref() {
            if let Ok(rel) = path.strip_prefix(root) {
                return rel.display().to_string();
            }
            if let (Ok(canon), Ok(root_canon)) = (path.canonicalize(), root.canonicalize()) {
                if let Ok(rel) = canon.strip_prefix(&root_canon) {
                    return rel.display().to_string();
                }
            }
        }
    }
    file.to_string()
}
