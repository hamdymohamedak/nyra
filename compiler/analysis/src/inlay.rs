//! Inferred type hints for zero-types mode (`let x = ...` without annotation).

use typecheck::{type_pretty, TypeChecker};

#[derive(Debug, Clone)]
pub struct InlayHintInfo {
    pub line: u32,
    pub character: u32,
    pub label: String,
    pub kind: InlayHintKind,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum InlayHintKind {
    Type,
    Parameter,
}

pub fn collect_inlay_hints(checker: &TypeChecker) -> Vec<InlayHintInfo> {
    checker
        .inferred_bindings
        .iter()
        .filter(|b| b.ty != typecheck::Type::Unknown)
        .map(|b| InlayHintInfo {
            line: (b.span.start.line.saturating_sub(1)) as u32,
            character: (b.span.end.column.saturating_sub(1)) as u32,
            label: format!(": {}", type_pretty(&b.ty)),
            kind: InlayHintKind::Type,
        })
        .collect()
}
