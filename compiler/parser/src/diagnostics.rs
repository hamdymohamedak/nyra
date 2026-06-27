use errors::{ErrorKind, NyraError, Span};
use lexer::{Token, TokenKind};
use crate::recovery::{check, merge_spans, skip_newlines};

/// `{` in expression position — diagnose empty blocks vs valid anonymous struct literals.
pub fn parse_leading_brace_expr(
    tokens: &[Token],
    position: &mut usize,
    errors: &mut Vec<NyraError>,
) -> bool {
    if !check(tokens, *position, &TokenKind::LBrace) {
        return false;
    }

    let brace_start = tokens[*position].span.clone();
    if looks_like_anonymous_object_literal(tokens, *position) {
        return false;
    }

    if looks_like_empty_block_expr(tokens, *position) {
        let span = skip_balanced_brace(tokens, position).unwrap_or(brace_start);
        errors.push(
            NyraError::coded(
                "P002",
                ErrorKind::Parser,
                span,
                "a standalone `{ }` block is not an expression",
            )
            .label("`{ }` is a statement block, not a value")
            .note("blocks run statements; they do not produce anonymous objects")
            .help("use a struct literal: `MyType { field: value }`"),
        );
        return true;
    }

    false
}

pub fn looks_like_anonymous_object_literal(tokens: &[Token], pos: usize) -> bool {
    let mut p = pos + 1;
    skip_newlines(tokens, &mut p);
    if check(tokens, p, &TokenKind::RBrace) {
        return false;
    }
    match tokens.get(p).map(|t| &t.kind) {
        Some(TokenKind::Identifier(_)) => {
            p += 1;
            skip_newlines(tokens, &mut p);
            check(tokens, p, &TokenKind::Colon)
        }
        Some(TokenKind::DotDot) | Some(TokenKind::DotDotDot) => true,
        _ => false,
    }
}

pub fn looks_like_empty_block_expr(tokens: &[Token], pos: usize) -> bool {
    let mut p = pos + 1;
    skip_newlines(tokens, &mut p);
    check(tokens, p, &TokenKind::RBrace)
}

pub fn skip_balanced_brace(tokens: &[Token], position: &mut usize) -> Option<Span> {
    if !check(tokens, *position, &TokenKind::LBrace) {
        return None;
    }
    let start = tokens[*position].span.clone();
    *position += 1;
    let mut depth = 1usize;
    let mut end = start.clone();
    while *position < tokens.len() && depth > 0 {
        match &tokens[*position].kind {
            TokenKind::LBrace => depth += 1,
            TokenKind::RBrace => {
                depth -= 1;
                end = tokens[*position].span.clone();
            }
            _ => {}
        }
        *position += 1;
    }
    Some(merge_spans(&start, &end))
}

#[cfg(test)]
mod tests {
    use super::*;
    use lexer::Lexer;

    fn parse_tokens(src: &str) -> Vec<Token> {
        Lexer::new(src, "test.ny").tokenize().0
    }

    #[test]
    fn detects_anonymous_object_spread_literal() {
        let tokens = parse_tokens(r#"let x = { ...obj, age: 21 }"#);
        assert!(looks_like_anonymous_object_literal(&tokens, 3));
    }

    #[test]
    fn detects_anonymous_object_literal() {
        let tokens = parse_tokens(r#"let x = { name: "a" }"#);
        assert!(looks_like_anonymous_object_literal(&tokens, 3));
    }

    #[test]
    fn empty_brace_is_not_object_literal() {
        let tokens = parse_tokens("let x = { }");
        assert!(!looks_like_anonymous_object_literal(&tokens, 3));
        assert!(looks_like_empty_block_expr(&tokens, 3));
    }
}
