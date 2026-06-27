//! LSP semantic tokens encoding.

use nyra_analysis::{collect_semantic_tokens, DocumentAnalysis, DocumentTokenKind, TokenModifiers};
use tower_lsp::lsp_types::{
    SemanticToken, SemanticTokenModifier, SemanticTokenType, SemanticTokens, SemanticTokensLegend,
    SemanticTokensResult,
};

const TOKEN_TYPES: &[SemanticTokenType] = &[
    SemanticTokenType::KEYWORD,
    SemanticTokenType::FUNCTION,
    SemanticTokenType::VARIABLE,
    SemanticTokenType::PARAMETER,
    SemanticTokenType::TYPE,
    SemanticTokenType::PROPERTY,
    SemanticTokenType::NUMBER,
    SemanticTokenType::STRING,
];

const TOKEN_MODIFIERS: &[SemanticTokenModifier] = &[
    SemanticTokenModifier::DECLARATION,
    SemanticTokenModifier::READONLY,
];

pub fn semantic_tokens_legend() -> SemanticTokensLegend {
    SemanticTokensLegend {
        token_types: TOKEN_TYPES.to_vec(),
        token_modifiers: TOKEN_MODIFIERS.to_vec(),
    }
}

pub fn encode_semantic_tokens(source: &str, analysis: &DocumentAnalysis) -> SemanticTokensResult {
    let tokens = collect_semantic_tokens(source, analysis);
    let mut data = Vec::new();
    let mut prev_line = 0u32;
    let mut prev_char = 0u32;
    for tok in tokens {
        let (delta_line, delta_char) = if tok.line == prev_line {
            (0, tok.character.saturating_sub(prev_char))
        } else {
            (tok.line.saturating_sub(prev_line), tok.character)
        };
        data.push(SemanticToken {
            delta_line,
            delta_start: delta_char,
            length: tok.length,
            token_type: token_type_index(tok.kind),
            token_modifiers_bitset: token_modifiers_bits(tok.modifiers),
        });
        prev_line = tok.line;
        prev_char = tok.character;
    }
    SemanticTokensResult::Tokens(SemanticTokens { result_id: None, data })
}

fn token_type_index(kind: DocumentTokenKind) -> u32 {
    match kind {
        DocumentTokenKind::Keyword => 0,
        DocumentTokenKind::Function => 1,
        DocumentTokenKind::Variable => 2,
        DocumentTokenKind::Parameter => 3,
        DocumentTokenKind::TypeName => 4,
        DocumentTokenKind::Field => 5,
        DocumentTokenKind::Number => 6,
        DocumentTokenKind::String => 7,
    }
}

fn token_modifiers_bits(m: TokenModifiers) -> u32 {
    let mut bits = 0u32;
    if m.contains(TokenModifiers::DECLARATION) {
        bits |= 1;
    }
    if m.contains(TokenModifiers::READONLY) {
        bits |= 2;
    }
    bits
}

#[cfg(test)]
mod tests {
    use super::*;
    use nyra_analysis::DocumentAnalysis;

    #[test]
    fn encodes_keyword_and_function() {
        let src = "fn main() { print(1) }\n";
        let analysis = DocumentAnalysis::analyze(src, "t.ny");
        let result = encode_semantic_tokens(src, &analysis);
        if let SemanticTokensResult::Tokens(tokens) = result {
            assert!(!tokens.data.is_empty());
        } else {
            panic!("expected tokens");
        }
    }
}
