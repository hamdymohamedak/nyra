//! Detect and recover from top-level-only items written inside a block.

use errors::{nested_top_level_item_error, NyraError, Span};
use lexer::{Token, TokenKind};

use crate::diagnostics::skip_balanced_brace;
use crate::recovery::{check, is_at_end, skip_newlines};

/// Skip a top-level declaration so parsing can continue in the enclosing block.
pub fn skip_nested_top_level_item(tokens: &[Token], position: &mut usize) {
    if *position >= tokens.len() {
        return;
    }
    match tokens[*position].kind.clone() {
        TokenKind::Import => {
            *position += 1;
            skip_newlines(tokens, position);
            if matches!(tokens.get(*position).map(|t| &t.kind), Some(TokenKind::StringLit(_))) {
                *position += 1;
            }
        }
        TokenKind::Struct | TokenKind::Enum | TokenKind::Trait | TokenKind::Macro => {
            skip_braced_type_decl(tokens, position);
        }
        TokenKind::Impl => {
            skip_impl_decl(tokens, position);
        }
        TokenKind::Fn | TokenKind::Test | TokenKind::Async | TokenKind::Extern => {
            skip_fn_body_decl(tokens, position);
        }
        TokenKind::Export => {
            *position += 1;
            skip_fn_body_decl(tokens, position);
        }
        TokenKind::Module => {
            *position += 1;
            while *position < tokens.len()
                && !matches!(
                    tokens[*position].kind,
                    TokenKind::Newline | TokenKind::Struct | TokenKind::Fn | TokenKind::Eof
                )
            {
                *position += 1;
            }
        }
        _ => {
            *position += 1;
        }
    }
}

fn skip_braced_type_decl(tokens: &[Token], position: &mut usize) {
    *position += 1;
    while *position < tokens.len() && !check(tokens, *position, &TokenKind::LBrace) {
        if is_at_end(tokens, *position) {
            return;
        }
        *position += 1;
    }
    let _ = skip_balanced_brace(tokens, position);
}

fn skip_impl_decl(tokens: &[Token], position: &mut usize) {
    *position += 1;
    while *position < tokens.len() && !check(tokens, *position, &TokenKind::LBrace) {
        if is_at_end(tokens, *position) {
            return;
        }
        *position += 1;
    }
    let _ = skip_balanced_brace(tokens, position);
}

fn skip_fn_body_decl(tokens: &[Token], position: &mut usize) {
    if *position < tokens.len() {
        *position += 1;
    }
    while *position < tokens.len() && !check(tokens, *position, &TokenKind::LBrace) {
        if is_at_end(tokens, *position) {
            return;
        }
        *position += 1;
    }
    let _ = skip_balanced_brace(tokens, position);
}

pub fn nested_item_diagnostic(span: Span, keyword: &str) -> NyraError {
    let (move_hint, example) = match keyword {
        "struct" => (
            "move `struct Name { ... }` above `fn main()`",
            "struct Family {\n    name: string\n    age: i32\n}\n\nfn main() {\n    let family = Family { name: \"hamdy\", age: 20 }\n}",
        ),
        "enum" => (
            "move `enum Name { ... }` above `fn main()`",
            "enum Color { Red Green Blue }\n\nfn main() {\n    let c = Color.Red\n}",
        ),
        "fn" | "async fn" | "test fn" => (
            "define helper functions next to `fn main()`, not inside it",
            "fn greet(name: string) -> void {\n    print(name)\n}\n\nfn main() {\n    greet(\"Nyra\")\n}",
        ),
        "impl" => (
            "move `impl Type { ... }` to the top level of the file",
            "struct Point { x: i32 }\n\nimpl Point {\n    fn zero() -> Point { Point { x: 0 } }\n}",
        ),
        "trait" => (
            "move `trait Name { ... }` to the top level of the file",
            "trait Show {\n    fn show(self) -> void\n}",
        ),
        "extern" => (
            "move `extern fn ...` declarations to the top level of the file",
            "extern fn vec_i32_new() -> ptr\n\nfn main() { ... }",
        ),
        "import" => (
            "move `import \"path.ny\"` to the top of the file (before `fn main`)",
            "import \"stdlib/vec.ny\"\n\nfn main() { ... }",
        ),
        "module" => (
            "put `module name` on the first line of the file",
            "module my.app\n\nfn main() { ... }",
        ),
        "macro" => (
            "move `macro name(...) => ...` to the top level of the file",
            "macro twice(x) => x + x\n\nfn main() { print(twice(1)) }",
        ),
        "export" => (
            "move `export fn ...` to the top level of the file",
            "export fn api_version() -> i32 { return 1 }",
        ),
        _ => (
            "move this item outside `fn main()` and other function bodies",
            "struct MyType { field: i32 }\n\nfn main() { ... }",
        ),
    };
    nested_top_level_item_error(span, keyword, move_hint, example)
}

#[cfg(test)]
mod tests {
    use super::*;
    use lexer::{Lexer, TokenKind};

    fn tokens(src: &str) -> Vec<Token> {
        Lexer::new(src, "t.ny").tokenize().0
    }

    #[test]
    fn skips_struct_inside_block() {
        let toks = tokens(
            r#"fn main() {
    struct Family { name: string age: i32 }
    print(0)
}"#,
        );
        let start = toks
            .iter()
            .position(|t| matches!(t.kind, TokenKind::Struct))
            .expect("struct token");
        let mut pos = start;
        skip_nested_top_level_item(&toks, &mut pos);
        assert!(pos > start);
        let remaining: Vec<_> = toks[pos..]
            .iter()
            .filter(|t| !matches!(t.kind, TokenKind::Newline))
            .map(|t| &t.kind)
            .collect();
        assert!(
            remaining.iter().any(|k| matches!(k, TokenKind::Print)),
            "expected print after skip, got {remaining:?}"
        );
    }
}
