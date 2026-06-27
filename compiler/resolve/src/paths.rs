use std::path::{Path, PathBuf};

/// Recognized Nyra source file extensions (`.ny` is canonical; `.nyra` is an alias).
pub const NYRA_EXTENSIONS: &[&str] = &["ny", "nyra"];

pub const MAIN_ENTRY_NAMES: &[&str] = &["main.ny", "main.nyra"];

pub fn is_nyra_source(path: &Path) -> bool {
    path.extension()
        .and_then(|e| e.to_str())
        .is_some_and(|ext| NYRA_EXTENSIONS.contains(&ext))
}

pub fn is_nyra_import_path(import_path: &str) -> bool {
    import_path.ends_with(".ny") || import_path.ends_with(".nyra")
}

/// Swap `.ny` ↔ `.nyra` so imports resolve either spelling (like TypeScript `.ts`/`.tsx`).
pub fn alternate_source_extension(import_path: &str) -> Option<String> {
    import_path
        .strip_suffix(".nyra")
        .map(|stem| format!("{}.ny", stem))
        .or_else(|| {
            import_path
                .strip_suffix(".ny")
                .map(|stem| format!("{}.nyra", stem))
        })
}

pub fn has_main_entry(dir: &Path) -> bool {
    MAIN_ENTRY_NAMES.iter().any(|name| dir.join(name).exists())
}

/// Prefer `main.ny` when both exist (backward compatible with existing projects).
pub fn find_main_entry(dir: &Path) -> Option<PathBuf> {
    MAIN_ENTRY_NAMES
        .iter()
        .map(|name| dir.join(name))
        .find(|p| p.exists())
}

pub fn is_legacy_test_file(path: &Path) -> bool {
    path.file_name()
        .and_then(|n| n.to_str())
        .is_some_and(|n| n.ends_with("_test.ny") || n.ends_with("_test.nyra"))
}

pub fn import_candidates(import_path: &str) -> Vec<String> {
    let mut candidates = vec![import_path.to_string()];
    if let Some(alt) = alternate_source_extension(import_path) {
        candidates.push(alt);
    }
    candidates
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn alternate_extension_roundtrip() {
        assert_eq!(
            alternate_source_extension("src/util.ny").as_deref(),
            Some("src/util.nyra")
        );
        assert_eq!(
            alternate_source_extension("src/util.nyra").as_deref(),
            Some("src/util.ny")
        );
        assert_eq!(alternate_source_extension("module.path"), None);
    }
}
