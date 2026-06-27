//! Multi-file workspace index for go-to-definition, references, and cross-file rename.

use std::collections::HashMap;
use std::path::{Path, PathBuf};

use errors::Span;
use resolve::collect_source_files;

use crate::{
    apply_rename, find_name_occurrences, position_in_span, word_at,
    DocumentAnalysis, Symbol, SymbolKind,
};

#[derive(Debug, Clone)]
pub struct SymbolLocation {
    pub file: String,
    pub span: Span,
    pub kind: SymbolKind,
    pub is_definition: bool,
    pub name: String,
}

#[derive(Debug, Clone)]
pub struct WorkspaceIndex {
    pub root: PathBuf,
    pub files: HashMap<String, String>,
    pub locations: Vec<SymbolLocation>,
}

impl WorkspaceIndex {
    /// Build index from a project directory (`main.ny` or `nyra.mod` root).
    pub fn from_project_root(root: &Path) -> Result<Self, String> {
        let main = resolve::paths::find_main_entry(root).ok_or_else(|| {
            format!("no main.ny in project root {}", root.display())
        })?;
        Self::from_file(&main)
    }

    pub fn canonical_file_key(path: &str) -> String {
        PathBuf::from(path)
            .canonicalize()
            .map(|p| p.to_string_lossy().into_owned())
            .unwrap_or_else(|_| path.to_string())
    }

    pub fn goto_definition_at(
        &self,
        file: &str,
        line: u32,
        character: u32,
    ) -> Option<SymbolLocation> {
        let key = Self::canonical_file_key(file);
        self.goto_definition(&key, line, character)
            .or_else(|| self.goto_definition(file, line, character))
    }

    pub fn find_references_at(
        &self,
        file: &str,
        line: u32,
        character: u32,
    ) -> Vec<SymbolLocation> {
        let key = Self::canonical_file_key(file);
        let refs = self.find_references(&key, line, character);
        if refs.is_empty() && key != file {
            self.find_references(file, line, character)
        } else {
            refs
        }
    }

    pub fn from_file(entry: &Path) -> Result<Self, String> {
        let entry = entry
            .canonicalize()
            .or_else(|_| Ok::<_, std::io::Error>(entry.to_path_buf()))
            .map_err(|e| e.to_string())?;
        let sources = collect_source_files(&entry)?;
        let root = project_root(&entry, &sources);
        let mut files = HashMap::new();
        let mut locations = Vec::new();

        for path in &sources {
            let file = path
                .canonicalize()
                .unwrap_or_else(|_| path.clone())
                .to_string_lossy()
                .into_owned();
            let source = std::fs::read_to_string(path)
                .map_err(|e| format!("read {}: {e}", path.display()))?;
            let analysis = DocumentAnalysis::analyze(&source, &file);
            for sym in &analysis.symbols {
                if sym.kind == SymbolKind::Keyword {
                    continue;
                }
                let is_definition = is_definition_symbol(sym);
                locations.push(SymbolLocation {
                    file: file.clone(),
                    span: sym.span.clone(),
                    kind: sym.kind,
                    is_definition,
                    name: sym.name.clone(),
                });
            }
            files.insert(file, source);
        }

        Ok(Self {
            root,
            files,
            locations,
        })
    }

    pub fn from_sources(
        root: PathBuf,
        files: HashMap<String, String>,
    ) -> Self {
        let mut locations = Vec::new();
        for (file, source) in &files {
            let analysis = DocumentAnalysis::analyze(source, file);
            for sym in &analysis.symbols {
                if sym.kind == SymbolKind::Keyword {
                    continue;
                }
                locations.push(SymbolLocation {
                    file: file.clone(),
                    span: sym.span.clone(),
                    kind: sym.kind,
                    is_definition: is_definition_symbol(sym),
                    name: sym.name.clone(),
                });
            }
        }
        Self {
            root,
            files,
            locations,
        }
    }

    pub fn symbol_at(&self, file: &str, line: u32, character: u32) -> Option<&SymbolLocation> {
        let source = self.files.get(file)?;
        let analysis = DocumentAnalysis::analyze(source, file);
        let sym = analysis.symbol_at_position(source, line, character)?;
        let line1 = line as usize + 1;
        let col1 = character as usize + 1;
        self.locations.iter().find(|loc| {
            loc.file == file
                && loc.name == sym.name
                && loc.kind == sym.kind
                && (position_in_span(line1, col1, &loc.span) || loc.span.start.line == 0)
        })
    }

    pub fn goto_definition(
        &self,
        file: &str,
        line: u32,
        character: u32,
    ) -> Option<SymbolLocation> {
        let source = self.files.get(file)?;
        let word = word_at(source, line, character)?;

        if let Some(struct_name) = word
            .strip_suffix("_json_encode")
            .or_else(|| word.strip_suffix("_json_decode"))
        {
            if let Some(loc) = self.locations.iter().find(|loc| {
                loc.is_definition && loc.name == struct_name && loc.kind == SymbolKind::Struct
            }) {
                return Some(loc.clone());
            }
        }

        let analysis = DocumentAnalysis::analyze(source, file);
        let sym = analysis.symbol_at_position(source, line, character);
        let kind = sym
            .filter(|s| s.name == word)
            .map(|s| s.kind)
            .unwrap_or(SymbolKind::Function);

        if let Some(sym) = sym {
            if sym.name == word && is_definition_symbol(sym) && sym.span.start.line > 0 {
                return Some(SymbolLocation {
                    file: file.into(),
                    span: sym.span.clone(),
                    kind: sym.kind,
                    is_definition: true,
                    name: sym.name.clone(),
                });
            }
        }

        let global_kinds = [
            SymbolKind::Function,
            SymbolKind::Struct,
            SymbolKind::Enum,
            SymbolKind::Constant,
            SymbolKind::Extern,
        ];
        if global_kinds.contains(&kind) {
            return self
                .locations
                .iter()
                .find(|loc| loc.is_definition && loc.name == word && loc.kind == kind)
                .cloned()
                .or_else(|| {
                    self.locations.iter().find(|loc| {
                        loc.is_definition && loc.name == word && matches!(loc.kind, SymbolKind::Function)
                    }).cloned()
                });
        }

        self.locations
            .iter()
            .find(|loc| {
                loc.file == file
                    && loc.is_definition
                    && loc.name == word
                    && loc.kind == kind
            })
            .cloned()
    }

    pub fn find_references(
        &self,
        file: &str,
        line: u32,
        character: u32,
    ) -> Vec<SymbolLocation> {
        let Some(def) = self.goto_definition(file, line, character) else {
            let source = match self.files.get(file) {
                Some(s) => s,
                None => return vec![],
            };
            let word = match word_at(source, line, character) {
                Some(w) => w,
                None => return vec![],
            };
            return self
                .locations
                .iter()
                .filter(|loc| loc.name == word && loc.file == file)
                .cloned()
                .collect();
        };

        if is_workspace_global(&def.kind) {
            let mut refs = Vec::new();
            if let Some(def_loc) = self
                .locations
                .iter()
                .find(|loc| loc.is_definition && loc.name == def.name)
            {
                refs.push(def_loc.clone());
            }
            for (file, source) in &self.files {
                for span in find_name_occurrences(source, file, &def.name) {
                    refs.push(SymbolLocation {
                        file: file.clone(),
                        span,
                        kind: def.kind,
                        is_definition: false,
                        name: def.name.clone(),
                    });
                }
            }
            return refs;
        }

        self.locations
            .iter()
            .filter(|loc| loc.file == def.file && loc.name == def.name && loc.kind == def.kind)
            .cloned()
            .collect()
    }

    pub fn workspace_rename(
        &self,
        file: &str,
        line: u32,
        character: u32,
        new_name: &str,
    ) -> HashMap<String, String> {
        let mut out = self.files.clone();
        let Some(anchor) = self.symbol_at(file, line, character) else {
            return out;
        };

        if is_workspace_global(&anchor.kind) {
            for (f, src) in &self.files.clone() {
                let updated = replace_identifier(src, &anchor.name, new_name);
                out.insert(f.clone(), updated);
            }
            return out;
        }

        if let Some(src) = out.get(file) {
            let analysis = DocumentAnalysis::analyze(src, file);
            if let Some(sym) = analysis.symbol_at_position(src, line, character) {
                out.insert(file.into(), apply_rename(src, sym, new_name));
            }
        }
        out
    }
}

fn is_workspace_global(kind: &SymbolKind) -> bool {
    matches!(
        kind,
        SymbolKind::Function
            | SymbolKind::Struct
            | SymbolKind::Enum
            | SymbolKind::Constant
            | SymbolKind::Extern
    )
}

fn is_definition_symbol(sym: &Symbol) -> bool {
    match sym.kind {
        SymbolKind::Function | SymbolKind::Constant | SymbolKind::Parameter => sym.renameable,
        SymbolKind::Variable => sym.renameable && sym.span.start.line > 0,
        SymbolKind::Struct | SymbolKind::Enum | SymbolKind::Extern => true,
        _ => false,
    }
}

fn project_root(entry: &Path, sources: &[PathBuf]) -> PathBuf {
    let mut dir = entry.parent().unwrap_or(Path::new(".")).to_path_buf();
    if entry.is_file() {
        // already parent
    } else {
        dir = entry.to_path_buf();
    }
    loop {
        if dir.join("nyra.mod").exists() || dir.join("main.ny").exists() {
            return dir;
        }
        if let Some(parent) = dir.parent() {
            if parent == dir {
                break;
            }
            dir = parent.to_path_buf();
        } else {
            break;
        }
    }
    sources
        .first()
        .and_then(|p| p.parent())
        .map(Path::to_path_buf)
        .unwrap_or_else(|| PathBuf::from("."))
}

pub fn span_to_lsp_range(span: &Span) -> (u32, u32, u32, u32) {
    (
        (span.start.line.saturating_sub(1)) as u32,
        (span.start.column.saturating_sub(1)) as u32,
        (span.end.line.saturating_sub(1)) as u32,
        (span.end.column.saturating_sub(1)) as u32,
    )
}

fn replace_identifier(source: &str, old: &str, new: &str) -> String {
    let mut out = source.to_string();
    let mut search_from = 0;
    while let Some(rel) = out[search_from..].find(old) {
        let start = search_from + rel;
        let end = start + old.len();
        let before_ok = start == 0 || !is_ident_byte(out.as_bytes()[start - 1]);
        let after_ok = end >= out.len() || !is_ident_byte(out.as_bytes()[end]);
        if before_ok && after_ok {
            out.replace_range(start..end, new);
            search_from = start + new.len();
        } else {
            search_from = end;
        }
    }
    out
}

fn is_ident_byte(b: u8) -> bool {
    b.is_ascii_alphanumeric() || b == b'_'
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::io::Write;

    #[test]
    fn goto_def_cross_file() {
        let tmp = std::env::temp_dir().join(format!("nyra_ws_{}", std::process::id()));
        let _ = std::fs::remove_dir_all(&tmp);
        std::fs::create_dir_all(tmp.join("src")).unwrap();
        std::fs::File::create(tmp.join("main.ny"))
            .unwrap()
            .write_all(b"import \"src/helper.ny\"\nfn main() { helper_fn() }\n")
            .unwrap();
        std::fs::File::create(tmp.join("src/helper.ny"))
            .unwrap()
            .write_all(b"fn helper_fn() { print(1) }\n")
            .unwrap();

        let ws = WorkspaceIndex::from_file(&tmp.join("main.ny")).unwrap();
        let main = tmp
            .join("main.ny")
            .canonicalize()
            .unwrap()
            .to_string_lossy()
            .into_owned();
        let line1 = "fn main() { helper_fn() }";
        let col = line1.find("helper_fn").unwrap() as u32;
        let def = ws.goto_definition(&main, 1, col).expect("def");
        assert_eq!(def.name, "helper_fn");
        assert!(def.file.contains("helper.ny"));
        let _ = std::fs::remove_dir_all(&tmp);
    }
}
