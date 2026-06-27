use std::path::PathBuf;

#[derive(Debug, Clone)]
pub struct BindConfig {
    pub header: PathBuf,
    pub includes: Vec<PathBuf>,
    pub defines: Vec<String>,
    pub link_libs: Vec<String>,
    /// Only emit functions whose name starts with this prefix.
    pub function_prefix: Option<String>,
    /// If non-empty, only these function names (exact or `sym*` glob prefix).
    pub export_filter: Vec<String>,
    pub output: Option<PathBuf>,
    pub update_mod: bool,
    /// When direct FFI mapping fails, emit C shims + `link-source`.
    pub generate_shims: bool,
}

impl BindConfig {
    pub fn shim_source_path(&self) -> String {
        "vendor/bindings/shim.c".into()
    }

    pub fn matches_export(&self, name: &str) -> bool {
        if let Some(ref prefix) = self.function_prefix {
            if !name.starts_with(prefix) {
                return false;
            }
        }
        if self.export_filter.is_empty() {
            return true;
        }
        self.export_filter.iter().any(|f| {
            if f.ends_with('*') {
                name.starts_with(f.trim_end_matches('*'))
            } else {
                f == name
            }
        })
    }
}
