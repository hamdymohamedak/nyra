//! Collect all `.ny` source files reachable from an entry point (import graph).

use std::collections::HashSet;
use std::path::{Path, PathBuf};

use ast::Program;
use lexer::Lexer;
use parser::Parser;

pub fn collect_source_files(entry: &Path) -> Result<Vec<PathBuf>, String> {
    let entry = entry.canonicalize().map_err(|e| e.to_string())?;
    let mut visited = HashSet::new();
    let mut files = Vec::new();
    collect_recursive(&entry, &mut visited, &mut files)?;
    files.sort();
    files.dedup();
    Ok(files)
}

fn collect_recursive(
    path: &Path,
    visited: &mut HashSet<PathBuf>,
    files: &mut Vec<PathBuf>,
) -> Result<(), String> {
    let path = path.canonicalize().map_err(|e| e.to_string())?;
    if !visited.insert(path.clone()) {
        return Ok(());
    }
    files.push(path.clone());

    let source = std::fs::read_to_string(&path)
        .map_err(|e| format!("Failed to read {}: {e}", path.display()))?;
    let file = path.to_string_lossy().into_owned();
    let (tokens, lex_errs) = Lexer::new(&source, &file).tokenize();
    if !lex_errs.is_empty() {
        return Ok(());
    }
    let (program, parse_errs) = Parser::new(tokens).parse();
    if !parse_errs.is_empty() {
        return Ok(());
    }
    let imports = program.imports;
    let base_dir = path.parent().unwrap_or(Path::new("."));
    for imp in imports {
        if let Ok(resolved) = super::resolve_import_path(base_dir, &imp.path) {
            collect_recursive(&resolved, visited, files)?;
        }
    }
    Ok(())
}

#[allow(dead_code)]
fn imports_only(program: &Program) -> Vec<String> {
    program.imports.iter().map(|i| i.path.clone()).collect()
}
