//! `nyra pkg c add|remove|list` — one-command system C library integration.

use std::collections::BTreeMap;
use std::path::{Path, PathBuf};
use std::process::Command;

use crate::bind::{bind_c, CBindOptions};
use crate::ui::Ui;

const MANIFEST: &str = "vendor/bindings/c-libs.toml";

#[derive(Debug, Clone)]
struct CatalogEntry {
    /// User-facing name (`raylib`, `zlib`, …).
    name: &'static str,
    /// Homebrew formula (macOS).
    brew: &'static str,
    /// Header file name under `{prefix}/include`.
    header: &'static str,
    /// `nyra.mod` link name (`link raylib`).
    link: &'static str,
    /// Debian/Ubuntu package hint (optional).
    apt: Option<&'static str>,
}

const CATALOG: &[CatalogEntry] = &[
    CatalogEntry {
        name: "raylib",
        brew: "raylib",
        header: "raylib.h",
        link: "raylib",
        apt: Some("libraylib-dev"),
    },
    CatalogEntry {
        name: "zlib",
        brew: "zlib",
        header: "zlib.h",
        link: "z",
        apt: Some("zlib1g-dev"),
    },
    CatalogEntry {
        name: "sqlite3",
        brew: "sqlite",
        header: "sqlite3.h",
        link: "sqlite3",
        apt: Some("libsqlite3-dev"),
    },
    CatalogEntry {
        name: "sdl2",
        brew: "sdl2",
        header: "SDL2/SDL.h",
        link: "SDL2",
        apt: Some("libsdl2-dev"),
    },
    CatalogEntry {
        name: "raygui",
        brew: "raylib",
        header: "raygui.h",
        link: "raylib",
        apt: Some("libraylib-dev"),
    },
];

#[derive(Debug, Clone, PartialEq, Eq)]
struct InstalledCLib {
    bindings: String,
    link: String,
    link_search: Vec<String>,
    header: String,
}

pub fn c_add(name: &str, project: Option<PathBuf>, no_install: bool) -> Result<(), String> {
    let root = project.unwrap_or_else(|| PathBuf::from("."));
    let catalog = find_catalog(name)?;
    let key = catalog.name.to_string();

    let (header, lib_dir, includes) = resolve_system_paths(catalog, no_install)?;

    if manifest_get(&root, &key)?.is_some() {
        let ui = Ui::new();
        eprintln!("{}", ui.dim(&format!("refreshing {key} bindings…")));
    }

    let stem = Path::new(catalog.header)
        .file_stem()
        .map(|s| s.to_string_lossy().into_owned())
        .unwrap_or_else(|| catalog.name.into());
    let bindings_rel = format!("vendor/bindings/{stem}.ny");

    bind_c(CBindOptions {
        header: header.clone(),
        project: Some(root.clone()),
        link_lib: vec![catalog.link.to_string()],
        include: includes,
        define: vec![],
        output: Some(root.join(&bindings_rel)),
        prefix: None,
        export: vec![],
        update_mod: true,
        stdout: false,
        generate_shims: false,
    })?;

    let link_search = if lib_dir.is_empty() {
        vec![]
    } else {
        vec![lib_dir]
    };

    apply_nyra_mod_links(&root, catalog.link, &link_search)?;
    write_manifest_entry(
        &root,
        &key,
        InstalledCLib {
            bindings: bindings_rel.clone(),
            link: catalog.link.to_string(),
            link_search: link_search.clone(),
            header: header.display().to_string(),
        },
    )?;

    let ui = Ui::new();
    let import = bindings_rel.replace('\\', "/");
    println!("{}", ui.success(&format!("{key} ready")));
    println!("{}", ui.field("import", &format!("\"{import}\"")));
    println!("{}", ui.field("header", &header.display().to_string()));
    println!("{}", ui.field("link", catalog.link));
    if catalog.name == "raylib" {
        println!("{}", ui.hint("nyra run .  — see examples/c_raylib/main.ny"));
    }
    Ok(())
}

pub fn c_remove(name: &str, project: Option<PathBuf>) -> Result<(), String> {
    let root = project.unwrap_or_else(|| PathBuf::from("."));
    let catalog = find_catalog(name)?;
    let key = catalog.name.to_string();

    let Some(entry) = manifest_remove(&root, &key)? else {
        return Err(format!("c-lib {key} is not installed in this project (no {MANIFEST} entry)"));
    };

    let ui = Ui::new();
    let bindings = root.join(&entry.bindings);
    if bindings.is_file() {
        std::fs::remove_file(&bindings).map_err(|e| e.to_string())?;
        println!(
            "{}  deleted {}",
            ui.yellow("−"),
            ui.path(&bindings.display().to_string())
        );
    }

    remove_nyra_mod_links(&root, &entry.link, &entry.link_search)?;

    println!("{}", ui.success(&format!("{key} removed from project")));
    Ok(())
}

pub fn c_list(project: Option<PathBuf>) -> Result<(), String> {
    let root = project.unwrap_or_else(|| PathBuf::from("."));
    let ui = Ui::new();
    let installed = manifest_read_all(&root)?;
    let project = root.display().to_string();

    if installed.is_empty() {
        println!("{}", ui.section("C libraries", &project));
        println!();
        println!("  {}", ui.dim("No C libraries installed"));
        println!();
        println!("  {}  {}", ui.dim("Add one"), ui.cmd("nyra pkg c add raylib"));
        println!();
        println!("  {}", ui.bold("Available"));
        for c in unique_catalog() {
            println!(
                "    {}  {}",
                ui.bold(c.name),
                ui.dim(&format!("brew install {}", c.brew))
            );
        }
        return Ok(());
    }

    println!("{}", ui.section("C libraries", &project));
    println!();
    for (name, entry) in &installed {
        println!("{}", ui.item(name));
        println!(
            "{}",
            ui.field("import", &format!("\"{}\"", entry.bindings))
        );
        println!("{}", ui.field("link", &entry.link));
        if !entry.header.is_empty() {
            println!("{}", ui.field("header", &entry.header));
        }
        println!();
    }
    let n = installed.len();
    let noun = if n == 1 { "library" } else { "libraries" };
    println!(
        "  {}  ·  add more with {}",
        ui.count(n, noun),
        ui.cmd("nyra pkg c add zlib")
    );
    Ok(())
}

fn unique_catalog() -> Vec<&'static CatalogEntry> {
    let mut seen = std::collections::HashSet::new();
    CATALOG
        .iter()
        .filter(|c| seen.insert(c.name))
        .collect()
}

fn find_catalog(name: &str) -> Result<&'static CatalogEntry, String> {
    let key = name.trim().to_ascii_lowercase();
    CATALOG
        .iter()
        .find(|c| {
            c.name == key
                || c.link == key
                || c.brew == key
                || (key == "sqlite" && c.name == "sqlite3")
        })
        .ok_or_else(|| {
            let known: Vec<_> = unique_catalog().iter().map(|c| c.name).collect();
            format!(
                "unknown c-lib '{name}' — supported: {}",
                known.join(", ")
            )
        })
}

fn resolve_system_paths(
    catalog: &CatalogEntry,
    no_install: bool,
) -> Result<(PathBuf, String, Vec<PathBuf>), String> {
    if cfg!(target_os = "macos") {
        resolve_macos(catalog, no_install)
    } else if cfg!(target_os = "linux") {
        resolve_linux(catalog, no_install)
    } else {
        Err("nyra pkg c add: macOS (Homebrew) and Linux are supported today".into())
    }
}

fn resolve_macos(
    catalog: &CatalogEntry,
    no_install: bool,
) -> Result<(PathBuf, String, Vec<PathBuf>), String> {
    let prefix = ensure_brew_prefix(catalog.brew, no_install)?;
    let include_dir = prefix.join("include");
    let header = include_dir.join(catalog.header);
    if !header.is_file() {
        return Err(format!(
            "header not found: {} (brew --prefix {})",
            header.display(),
            catalog.brew
        ));
    }
    let lib_dir = prefix.join("lib").display().to_string();
    let mut includes = vec![include_dir];
    includes.extend(clang_system_includes()?);
    Ok((header, lib_dir, includes))
}

fn resolve_linux(
    catalog: &CatalogEntry,
    no_install: bool,
) -> Result<(PathBuf, String, Vec<PathBuf>), String> {
    let candidates = [
        PathBuf::from("/usr/include").join(catalog.header),
        PathBuf::from("/usr/local/include").join(catalog.header),
    ];
    let header = candidates
        .into_iter()
        .find(|p| p.is_file())
        .ok_or_else(|| {
            let hint = catalog
                .apt
                .map(|p| format!("sudo apt install {p}"))
                .unwrap_or_else(|| format!("install dev package for {}", catalog.name));
            if no_install {
                format!("header not found for {}; {}", catalog.name, hint)
            } else {
                format!(
                    "header not found for {} — run: {}",
                    catalog.name, hint
                )
            }
        })?;

    let lib_dir = if Path::new("/usr/lib/x86_64-linux-gnu").is_dir() {
        "/usr/lib/x86_64-linux-gnu".into()
    } else {
        String::new()
    };

    let mut includes = vec![PathBuf::from("/usr/include")];
    includes.extend(clang_system_includes()?);
    Ok((header, lib_dir, includes))
}

fn ensure_brew_prefix(formula: &str, no_install: bool) -> Result<PathBuf, String> {
    if let Ok(p) = brew_prefix(formula) {
        return Ok(p);
    }
    if no_install {
        return Err(format!(
            "{formula} not installed — run: brew install {formula}"
        ));
    }
    eprintln!("{}", Ui::new().dim(&format!("installing {formula} via Homebrew…")));
    let status = Command::new("brew")
        .args(["install", formula])
        .status()
        .map_err(|e| format!("failed to run brew install: {e}"))?;
    if !status.success() {
        return Err(format!("brew install {formula} failed"));
    }
    brew_prefix(formula)
}

fn brew_prefix(formula: &str) -> Result<PathBuf, String> {
    let out = Command::new("brew")
        .args(["--prefix", formula])
        .output()
        .map_err(|e| format!("brew not found: {e}"))?;
    if !out.status.success() {
        return Err(format!("brew --prefix {formula} failed"));
    }
    let path = String::from_utf8_lossy(&out.stdout).trim().to_string();
    if path.is_empty() {
        return Err(format!("empty prefix for {formula}"));
    }
    Ok(PathBuf::from(path))
}

fn clang_system_includes() -> Result<Vec<PathBuf>, String> {
    let mut paths = Vec::new();
    if cfg!(target_os = "macos") {
        if let Ok(out) = Command::new("xcrun").args(["--show-sdk-path"]).output() {
            if out.status.success() {
                let sdk = String::from_utf8_lossy(&out.stdout).trim().to_string();
                if !sdk.is_empty() {
                    paths.push(PathBuf::from(sdk).join("usr/include"));
                }
            }
        }
    }
    if let Ok(out) = Command::new("brew").args(["--prefix", "llvm"]).output() {
        if out.status.success() {
            let llvm = String::from_utf8_lossy(&out.stdout).trim().to_string();
            if !llvm.is_empty() {
                let clang_dir = PathBuf::from(&llvm).join("lib/clang");
                if let Ok(entries) = std::fs::read_dir(&clang_dir) {
                    let mut vers: Vec<_> = entries.filter_map(|e| e.ok()).collect();
                    vers.sort_by_key(|e| e.file_name());
                    if let Some(last) = vers.last() {
                        paths.push(last.path().join("include"));
                    }
                }
            }
        }
    }
    Ok(paths)
}

fn manifest_path(root: &Path) -> PathBuf {
    root.join(MANIFEST)
}

fn manifest_read_all(root: &Path) -> Result<BTreeMap<String, InstalledCLib>, String> {
    let path = manifest_path(root);
    if !path.is_file() {
        return Ok(BTreeMap::new());
    }
    let text = std::fs::read_to_string(&path).map_err(|e| e.to_string())?;
    parse_manifest(&text)
}

fn manifest_get(root: &Path, name: &str) -> Result<Option<InstalledCLib>, String> {
    Ok(manifest_read_all(root)?.get(name).cloned())
}

fn write_manifest_entry(root: &Path, name: &str, entry: InstalledCLib) -> Result<(), String> {
    let mut all = manifest_read_all(root)?;
    all.insert(name.to_string(), entry);
    let path = manifest_path(root);
    if let Some(parent) = path.parent() {
        std::fs::create_dir_all(parent).map_err(|e| e.to_string())?;
    }
    std::fs::write(&path, render_manifest(&all)).map_err(|e| e.to_string())?;
    Ok(())
}

fn manifest_remove(root: &Path, name: &str) -> Result<Option<InstalledCLib>, String> {
    let mut all = manifest_read_all(root)?;
    let removed = all.remove(name);
    let path = manifest_path(root);
    if all.is_empty() {
        if path.is_file() {
            std::fs::remove_file(&path).ok();
        }
    } else if path.parent().is_some() {
        std::fs::write(&path, render_manifest(&all)).map_err(|e| e.to_string())?;
    }
    Ok(removed)
}

fn parse_manifest(text: &str) -> Result<BTreeMap<String, InstalledCLib>, String> {
    let doc: toml::Table = toml::from_str(text).map_err(|e| format!("{MANIFEST}: {e}"))?;
    let mut out = BTreeMap::new();
    for (name, val) in &doc {
        if name == "libs" {
            continue;
        }
        let t = val
            .as_table()
            .ok_or_else(|| format!("{MANIFEST}: [{name}] must be a table"))?;
        let bindings = t
            .get("bindings")
            .and_then(|v| v.as_str())
            .ok_or_else(|| format!("{MANIFEST}: [{name}.bindings]"))?
            .to_string();
        let link = t
            .get("link")
            .and_then(|v| v.as_str())
            .ok_or_else(|| format!("{MANIFEST}: [{name}.link]"))?
            .to_string();
        let header = t
            .get("header")
            .and_then(|v| v.as_str())
            .unwrap_or("")
            .to_string();
        let link_search = t
            .get("link_search")
            .and_then(|v| v.as_array())
            .map(|arr| {
                arr.iter()
                    .filter_map(|v| v.as_str().map(str::to_string))
                    .collect()
            })
            .unwrap_or_default();
        out.insert(
            name.clone(),
            InstalledCLib {
                bindings,
                link,
                link_search,
                header,
            },
        );
    }
    Ok(out)
}

fn render_manifest(libs: &BTreeMap<String, InstalledCLib>) -> String {
    let mut out = String::from(
        "# Managed by `nyra pkg c add|remove` — tracks system C libraries in this project.\n",
    );
    for (name, e) in libs {
        out.push_str(&format!("\n[{name}]\n"));
        out.push_str(&format!("bindings = \"{}\"\n", e.bindings));
        out.push_str(&format!("link = \"{}\"\n", e.link));
        out.push_str(&format!("header = \"{}\"\n", e.header));
        if !e.link_search.is_empty() {
            out.push_str("link_search = [");
            for (i, p) in e.link_search.iter().enumerate() {
                if i > 0 {
                    out.push_str(", ");
                }
                out.push_str(&format!("\"{p}\""));
            }
            out.push_str("]\n");
        }
    }
    out
}

fn apply_nyra_mod_links(root: &Path, link: &str, search: &[String]) -> Result<(), String> {
    let mod_path = root.join("nyra.mod");
    let mut text = if mod_path.is_file() {
        std::fs::read_to_string(&mod_path).map_err(|e| e.to_string())?
    } else {
        "module example.local\n\n".into()
    };

    strip_wrong_include_link_lines(&mut text);

    let link_line = format!("link {link}");
    if !text.lines().any(|l| l.trim() == link_line) {
        if !text.ends_with('\n') {
            text.push('\n');
        }
        text.push_str(&link_line);
        text.push('\n');
    }
    for dir in search {
        let line = format!("link -L {dir}");
        if !text.lines().any(|l| l.trim() == line) {
            text.push_str(&line);
            text.push('\n');
        }
    }

    std::fs::write(&mod_path, text).map_err(|e| e.to_string())?;
    Ok(())
}

fn remove_nyra_mod_links(root: &Path, link: &str, search: &[String]) -> Result<(), String> {
    let mod_path = root.join("nyra.mod");
    if !mod_path.is_file() {
        return Ok(());
    }
    let mut lines: Vec<String> = std::fs::read_to_string(&mod_path)
        .map_err(|e| e.to_string())?
        .lines()
        .map(str::to_string)
        .collect();

    let link_line = format!("link {link}");
    lines.retain(|l| l.trim() != link_line);
    for dir in search {
        let line = format!("link -L {dir}");
        lines.retain(|l| l.trim() != line);
    }

    let mut text = lines.join("\n");
    if !text.ends_with('\n') {
        text.push('\n');
    }
    std::fs::write(&mod_path, text).map_err(|e| e.to_string())?;
    Ok(())
}

/// Remove mistaken `link -L` lines pointing at include/sdk paths from older bindgen.
fn strip_wrong_include_link_lines(text: &mut String) {
    let mut kept = Vec::new();
    for line in text.lines() {
        let trim = line.trim();
        if trim.starts_with("link -L ") {
            let path = trim.trim_start_matches("link -L ").trim();
            if path.contains("/include")
                || path.contains("MacOSX.sdk")
                || path.contains("/lib/clang/")
            {
                continue;
            }
        }
        kept.push(line);
    }
    let mut out = kept.join("\n");
    if !out.is_empty() {
        out.push('\n');
    }
    *text = out;
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn manifest_roundtrip() {
        let mut m = BTreeMap::new();
        m.insert(
            "raylib".into(),
            InstalledCLib {
                bindings: "vendor/bindings/raylib.ny".into(),
                link: "raylib".into(),
                link_search: vec!["/opt/homebrew/opt/raylib/lib".into()],
                header: "/opt/homebrew/opt/raylib/include/raylib.h".into(),
            },
        );
        let text = render_manifest(&m);
        let back = parse_manifest(&text).unwrap();
        assert_eq!(back.get("raylib"), m.get("raylib"));
    }

    #[test]
    fn strips_include_link_lines() {
        let mut text = "link raylib\nlink -L /opt/homebrew/opt/raylib/lib\nlink -L /opt/homebrew/opt/raylib/include\n".into();
        strip_wrong_include_link_lines(&mut text);
        assert!(text.contains("link raylib"));
        assert!(text.contains("raylib/lib"));
        assert!(!text.contains("raylib/include"));
    }

    #[test]
    fn catalog_resolves_aliases() {
        assert_eq!(find_catalog("sqlite3").unwrap().name, "sqlite3");
        assert_eq!(find_catalog("sqlite").unwrap().name, "sqlite3");
        assert_eq!(find_catalog("z").unwrap().name, "zlib");
    }
}
