//! Regression: malformed `async` without `fn` must not hang the parser.
use lexer::Lexer;
use parser::Parser;
use std::time::{Duration, Instant};

#[test]
fn parser_async_without_fn_does_not_hang() {
    let src = r#"async "auuzue" no_std "lx" "xnalae" _5182 }self "v" }5162 )703 _3009 _8777 struct :_8977 #7312 ]_5170 6078 _1431 self "f" "gqpkjzyvqunb" _6888 _2509 <=defer 5473 _6956 _3534 "animio" "gkrs" for 9136 6829 168 _2715 ||_9700 ;"sweqlooeb" 4232 "egktv" "mavuxaojm" "nklzwxzvfcan" dyn _1543 ,:<<"jpjep" (>>"#;
    let (tokens, _) = Lexer::new(src, "fuzz.ny").tokenize();
    let start = Instant::now();
    let (_program, _parse_err) = Parser::new(tokens).parse();
    assert!(
        start.elapsed() < Duration::from_secs(5),
        "parser hung on async-without-fn fuzz input"
    );
}

#[test]
fn parser_impl_block_with_let_does_not_hang() {
    let src = "enum E { A, B\nimport \"\nimpl T for U {let 2492 \"rnwym\" \"hlyasifkoz\" =>\"gxklw\" 8689 macro ";
    let (tokens, _) = Lexer::new(src, "fuzz.ny").tokenize();
    let start = Instant::now();
    let _ = Parser::new(tokens).parse();
    assert!(
        start.elapsed() < Duration::from_secs(5),
        "parser hung on impl-block-with-let fuzz input"
    );
}
