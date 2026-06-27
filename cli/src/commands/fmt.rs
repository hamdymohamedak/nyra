use std::path::Path;

use compiler::paths;

pub(crate) fn fmt_path(path: &Path, write: bool, check: bool) -> Result<(), String> {
    let changed = fmt_path_inner(path, write, check)?;
    if check && changed {
        return Err("format check failed: files need formatting (run nyra fmt --write)".into());
    }
    Ok(())
}

pub(crate) fn fmt_path_inner(path: &Path, write: bool, check: bool) -> Result<bool, String> {
    if path.is_file() && paths::is_nyra_source(path) {
        return fmt_one(path, write, check);
    }
    let mut changed = false;
    for entry in std::fs::read_dir(path).map_err(|e| e.to_string())? {
        let entry = entry.map_err(|e| e.to_string())?;
        let p = entry.path();
        if p.is_dir() {
            changed |= fmt_path_inner(&p, write, check)?;
        } else if paths::is_nyra_source(&p) {
            changed |= fmt_one(&p, write, check)?;
        }
    }
    Ok(changed)
}

fn fmt_one(path: &Path, write: bool, check: bool) -> Result<bool, String> {
    let (src, formatted) = crate::fmt::format_file(path)?;
    if formatted == src {
        if !check && !write {
            print!("{formatted}");
        }
        return Ok(false);
    }
    if check {
        eprintln!("would reformat {}", path.display());
        return Ok(true);
    }
    if write {
        std::fs::write(path, &formatted).map_err(|e| e.to_string())?;
        println!("formatted {}", path.display());
    } else {
        print!("{formatted}");
    }
    Ok(true)
}
