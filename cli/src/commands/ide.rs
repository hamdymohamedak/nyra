use std::path::{Path, PathBuf};

use compiler::paths;
use nyra_analysis::{span_to_lsp_range, WorkspaceIndex};

use crate::app::args::IdeCommands;

pub(crate) fn ide_command(cmd: IdeCommands) -> Result<(), String> {
    match cmd {
        IdeCommands::GotoDef {
            file,
            line,
            character,
        } => {
            let entry = project_entry_for(&file)?;
            let ws = WorkspaceIndex::from_file(&entry)?;
            let path = file
                .canonicalize()
                .unwrap_or(file)
                .to_string_lossy()
                .into_owned();
            let def = ws
                .goto_definition_at(&path, line, character)
                .ok_or("no definition found")?;
            let (sl, sc, _, _) = span_to_lsp_range(&def.span);
            println!("{}:{}:{}", def.file, sl + 1, sc + 1);
            Ok(())
        }
        IdeCommands::References {
            file,
            line,
            character,
        } => {
            let entry = project_entry_for(&file)?;
            let ws = WorkspaceIndex::from_file(&entry)?;
            let path = file
                .canonicalize()
                .unwrap_or(file)
                .to_string_lossy()
                .into_owned();
            let refs = ws.find_references_at(&path, line, character);
            let out: Vec<_> = refs
                .iter()
                .map(|r| {
                    let (sl, sc, el, ec) = span_to_lsp_range(&r.span);
                    serde_json::json!({
                        "file": r.file,
                        "start": { "line": sl, "character": sc },
                        "end": { "line": el, "character": ec },
                        "name": r.name,
                    })
                })
                .collect();
            println!("{}", serde_json::to_string_pretty(&out).map_err(|e| e.to_string())?);
            Ok(())
        }
    }
}

pub(crate) fn project_entry_for(path: &Path) -> Result<PathBuf, String> {
    if path.is_dir() {
        return paths::find_main_entry(path).ok_or_else(|| "no main.ny in directory".into());
    }
    let mut dir = path
        .parent()
        .map(Path::to_path_buf)
        .unwrap_or_else(|| PathBuf::from("."));
    loop {
        if let Some(main) = paths::find_main_entry(&dir) {
            return Ok(main);
        }
        if !dir.pop() {
            break;
        }
    }
    if path.is_file() {
        return Ok(path.to_path_buf());
    }
    Err("no main.ny in project".into())
}
