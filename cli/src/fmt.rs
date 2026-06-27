use std::path::Path;

pub fn format_file(path: &Path) -> Result<(String, String), String> {
    let src = std::fs::read_to_string(path).map_err(|e| e.to_string())?;
    let file = path.to_string_lossy();
    let formatted = nyra_fmt::format_source_or_fallback(&src, &file);
    Ok((src, formatted))
}
