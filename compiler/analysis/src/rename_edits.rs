//! Span-accurate rename edits for LSP `textDocument/rename`.

use std::collections::HashMap;

use errors::Span;

use crate::{
    find_name_occurrences, word_at, DocumentAnalysis, Symbol, SymbolKind, WorkspaceIndex,
};

#[derive(Debug, Clone)]
pub struct RenameTextEdit {
    pub span: Span,
    pub new_text: String,
}

impl WorkspaceIndex {
    /// Produce per-file span edits instead of full-document replacements.
    pub fn workspace_rename_edits(
        &self,
        file: &str,
        line: u32,
        character: u32,
        new_name: &str,
    ) -> HashMap<String, Vec<RenameTextEdit>> {
        let mut out: HashMap<String, Vec<RenameTextEdit>> = HashMap::new();
        if new_name.is_empty() {
            return out;
        }
        let Some(anchor) = self.symbol_at(file, line, character) else {
            return out;
        };

        if is_workspace_global(&anchor.kind) {
            for (f, source) in &self.files {
                for span in find_name_occurrences(source, f, &anchor.name) {
                    out.entry(f.clone()).or_default().push(RenameTextEdit {
                        span,
                        new_text: new_name.to_string(),
                    });
                }
            }
            return out;
        }

        if let Some(source) = self.files.get(file) {
            let analysis = DocumentAnalysis::analyze(source, file);
            if let Some(sym) = analysis.symbol_at_position(source, line, character) {
                push_local_rename_edits(&mut out, source, file, sym, new_name);
            }
        }
        out
    }
}

fn push_local_rename_edits(
    out: &mut HashMap<String, Vec<RenameTextEdit>>,
    source: &str,
    file: &str,
    sym: &Symbol,
    new_name: &str,
) {
    let analysis = DocumentAnalysis::analyze(source, file);
    for span in analysis.rename_ranges(sym) {
        out.entry(file.to_string()).or_default().push(RenameTextEdit {
            span,
            new_text: new_name.to_string(),
        });
    }
    if out.get(file).is_none() {
        if let Some(word) = word_at(source, (sym.span.start.line - 1) as u32, (sym.span.start.column - 1) as u32) {
            for span in find_name_occurrences(source, file, &word) {
                out.entry(file.to_string()).or_default().push(RenameTextEdit {
                    span,
                    new_text: new_name.to_string(),
                });
            }
        }
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
