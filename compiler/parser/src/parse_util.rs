//! Token stream helpers shared across the parser.
use errors::Span;
use lexer::TokenKind;
use super::recovery::skip_newlines;

use super::Parser;

impl Parser {
    pub(super) fn current_kind(&self) -> &TokenKind {
        self.tokens
            .get(self.position)
            .or_else(|| self.tokens.last())
            .map(|t| &t.kind)
            .expect("parser requires at least one token")
    }

    pub(super) fn current_span(&self) -> Span {
        self.tokens
            .get(self.position)
            .map(|t| t.span.clone())
            .unwrap_or_default()
    }

    pub(super) fn prev_span(&self) -> Span {
        if self.position == 0 {
            return self.current_span();
        }
        self.tokens[self.position - 1].span.clone()
    }

    pub(super) fn advance(&mut self) {
        if self.position < self.tokens.len() {
            self.position += 1;
            skip_newlines(&self.tokens, &mut self.position);
        }
    }
}

