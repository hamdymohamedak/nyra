//! Parser diagnostic helpers — coded errors on `Parser`.

use errors::coded_parser_error;
use errors::Span;

use crate::recovery::MAX_PARSE_ERRORS;
use crate::Parser;

impl Parser {
    pub(crate) fn errors_over_limit(&self) -> bool {
        self.errors.len() >= MAX_PARSE_ERRORS
    }

    pub(crate) fn parse_error(&mut self, span: Span, message: impl AsRef<str>) {
        if self.errors_over_limit() {
            return;
        }
        self.errors
            .push(coded_parser_error(span, message.as_ref()));
    }

    pub(crate) fn parse_error_here(&mut self, message: impl AsRef<str>) {
        let span = self.current_span();
        self.parse_error(span, message);
    }
}
