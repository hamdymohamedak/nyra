//! Semantic token spans for LSP syntax highlighting.

use crate::{DocumentAnalysis, SymbolKind, KEYWORDS};

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum DocumentTokenKind {
    Keyword,
    Function,
    Variable,
    Parameter,
    TypeName,
    Field,
    Number,
    String,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq, Default)]
pub struct TokenModifiers(u8);

impl TokenModifiers {
    pub const DECLARATION: Self = Self(1);
    pub const READONLY: Self = Self(2);

    pub const fn empty() -> Self {
        Self(0)
    }

    pub const fn contains(self, other: Self) -> bool {
        self.0 & other.0 == other.0
    }

    pub fn insert(&mut self, other: Self) {
        self.0 |= other.0;
    }
}

#[derive(Debug, Clone)]
pub struct DocumentToken {
    pub line: u32,
    pub character: u32,
    pub length: u32,
    pub kind: DocumentTokenKind,
    pub modifiers: TokenModifiers,
}

pub fn collect_semantic_tokens(source: &str, analysis: &DocumentAnalysis) -> Vec<DocumentToken> {
    let mut tokens = Vec::new();
    for kw in KEYWORDS {
        for (line_idx, line) in source.lines().enumerate() {
            let mut start = 0;
            while let Some(rel) = line[start..].find(kw) {
                let col = start + rel;
                let end = col + kw.len();
                let before_ok = col == 0 || !is_ident_byte(line.as_bytes()[col - 1]);
                let after_ok = end >= line.len() || !is_ident_byte(line.as_bytes()[end]);
                if before_ok && after_ok {
                    tokens.push(DocumentToken {
                        line: line_idx as u32,
                        character: col as u32,
                        length: kw.len() as u32,
                        kind: DocumentTokenKind::Keyword,
                        modifiers: TokenModifiers::empty(),
                    });
                }
                start = end;
            }
        }
    }
    for sym in &analysis.symbols {
        if sym.span.start.line == 0 {
            continue;
        }
        let (kind, modifiers) = symbol_token(sym.kind, sym.renameable);
        let line = (sym.span.start.line - 1) as u32;
        let character = (sym.span.start.column - 1) as u32;
        let length = sym.name.len() as u32;
        if length == 0 {
            continue;
        }
        tokens.push(DocumentToken {
            line,
            character,
            length,
            kind,
            modifiers,
        });
    }
    scan_literal_tokens(source, &mut tokens);
    tokens.sort_by(|a, b| {
        a.line
            .cmp(&b.line)
            .then(a.character.cmp(&b.character))
            .then(b.length.cmp(&a.length))
    });
    tokens.dedup_by(|a, b| a.line == b.line && a.character == b.character);
    tokens
}

fn symbol_token(kind: SymbolKind, renameable: bool) -> (DocumentTokenKind, TokenModifiers) {
    let mut modifiers = TokenModifiers::empty();
    if renameable {
        modifiers.insert(TokenModifiers::DECLARATION);
    }
    match kind {
        SymbolKind::Function | SymbolKind::Method | SymbolKind::Extern => {
            (DocumentTokenKind::Function, modifiers)
        }
        SymbolKind::Parameter => (DocumentTokenKind::Parameter, modifiers),
        SymbolKind::Variable | SymbolKind::Constant => {
            (DocumentTokenKind::Variable, modifiers)
        }
        SymbolKind::Struct | SymbolKind::Enum => (DocumentTokenKind::TypeName, modifiers),
        SymbolKind::Field => (DocumentTokenKind::Field, modifiers),
        _ => (DocumentTokenKind::Variable, modifiers),
    }
}

fn scan_literal_tokens(source: &str, tokens: &mut Vec<DocumentToken>) {
    let mut line = 0u32;
    let mut col = 0u32;
    let mut chars = source.chars().peekable();
    while let Some(ch) = chars.next() {
        if ch == '\n' {
            line += 1;
            col = 0;
            continue;
        }
        if ch.is_ascii_digit() {
            let start_col = col;
            let mut len = 1u32;
            while chars
                .peek()
                .is_some_and(|c| c.is_ascii_digit() || *c == '.')
            {
                chars.next();
                len += 1;
                col += 1;
            }
            tokens.push(DocumentToken {
                line,
                character: start_col,
                length: len,
                kind: DocumentTokenKind::Number,
                modifiers: TokenModifiers::empty(),
            });
            col += 1;
            continue;
        }
        if ch == '"' {
            let start_col = col;
            let mut len = 1u32;
            col += 1;
            while let Some(next) = chars.next() {
                len += 1;
                col += 1;
                if next == '\\' {
                    if chars.next().is_some() {
                        len += 1;
                        col += 1;
                    }
                } else if next == '"' {
                    break;
                }
            }
            tokens.push(DocumentToken {
                line,
                character: start_col,
                length: len,
                kind: DocumentTokenKind::String,
                modifiers: TokenModifiers::empty(),
            });
            continue;
        }
        col += 1;
    }
}

fn is_ident_byte(b: u8) -> bool {
    b.is_ascii_alphanumeric() || b == b'_'
}
