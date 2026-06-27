//! Static explanations for stable diagnostic codes (`nyra explain E003`).

/// One entry returned by [`explain`].
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ExplainEntry {
    pub code: &'static str,
    pub title: &'static str,
    pub explanation: &'static str,
    pub example_bad: Option<&'static str>,
    pub example_good: Option<&'static str>,
}

const ENTRIES: &[ExplainEntry] = &[
    ExplainEntry {
        code: "E001",
        title: "import not found",
        explanation: "An `import \"path\"` could not be resolved to a file on disk or in the package cache.",
        example_bad: Some("import \"missing/module.ny\""),
        example_good: Some("import \"stdlib/io.ny\"  // or a path relative to the project root"),
    },
    ExplainEntry {
        code: "E002",
        title: "undefined name",
        explanation: "A variable, function, or type name is used but was never declared in scope.",
        example_bad: Some("print(unknown)"),
        example_good: Some("fn greet() { print(\"hi\") }\nfn main() { greet() }"),
    },
    ExplainEntry {
        code: "E003",
        title: "type mismatch",
        explanation: "An expression's type does not match what the context expects (parameter, return, assignment, or operator).",
        example_bad: Some("fn f(x: i32) {}\nfn main() { f(\"text\") }"),
        example_good: Some("fn f(x: i32) {}\nfn main() { f(42) }"),
    },
    ExplainEntry {
        code: "E004",
        title: "cannot infer type",
        explanation: "The compiler could not infer a type for a binding or expression. Add an explicit annotation.",
        example_bad: Some("let x = []"),
        example_good: Some("let x: [i32] = []\n// or: let x = [1, 2, 3]"),
    },
    ExplainEntry {
        code: "E005",
        title: "unknown struct",
        explanation: "A struct literal or type name refers to a struct that is not defined or not in scope.",
        example_bad: Some("let p = Person { name: \"Ada\" }"),
        example_good: Some("struct Person { name: string }\nfn main() { let p = Person { name: \"Ada\" } }"),
    },
    ExplainEntry {
        code: "E006",
        title: "immutable assignment",
        explanation: "A binding declared with `let` cannot be reassigned. Use `var` for mutable bindings.",
        example_bad: Some("let x = 1\nx = 2"),
        example_good: Some("var x = 1\nx = 2"),
    },
    ExplainEntry {
        code: "E007",
        title: "wrong arity",
        explanation: "A function was called with the wrong number of arguments.",
        example_bad: Some("fn add(a: i32, b: i32) -> i32 { a + b }\nfn main() { add(1) }"),
        example_good: Some("fn add(a: i32, b: i32) -> i32 { a + b }\nfn main() { add(1, 2) }"),
    },
    ExplainEntry {
        code: "E008",
        title: "wrong argument type",
        explanation: "A specific argument position has the wrong type, even when the call arity is correct.",
        example_bad: Some("fn log(n: i32) {}\nfn main() { log(true) }"),
        example_good: Some("fn log(n: i32) {}\nfn main() { log(42) }"),
    },
    ExplainEntry {
        code: "E009",
        title: "invalid assignment target",
        explanation: "The left-hand side of an assignment is not a valid l-value (variable, field, or index).",
        example_bad: Some("1 = x"),
        example_good: Some("var x = 0\nx = 1"),
    },
    ExplainEntry {
        code: "E010",
        title: "borrow while assigned",
        explanation: "A mutable borrow conflicts with an existing assignment or mutable borrow of the same binding.",
        example_bad: Some("var x = 1\nlet a = &mut x\nx = 2"),
        example_good: Some("var x = 1\nx = 2\nlet a = &x"),
    },
    ExplainEntry {
        code: "E011",
        title: "use while borrowed",
        explanation: "A value is used while an active borrow still holds a reference to it.",
        example_bad: Some("let x = 1\nlet r = &x\nprint(x)"),
        example_good: Some("let x = 1\nlet r = &x\nprint(r)"),
    },
    ExplainEntry {
        code: "E012",
        title: "use after move",
        explanation: "A move-type value was moved (into a call, assignment, or closure) and then used again.",
        example_bad: Some("fn take(s: string) {}\nfn main() {\n    let name = \"Ada\"\n    take(name)\n    print(name)\n}"),
        example_good: Some("fn take(s: string) {}\nfn main() {\n    let name = \"Ada\"\n    take(clone name)\n    print(name)\n}"),
    },
    ExplainEntry {
        code: "W001",
        title: "extended tier feature",
        explanation: "The code uses an Extended-tier feature (async, traits, spawn, defer, etc.) while `--deny-extended` is active.",
        example_bad: Some("async fn fetch() { }  // with --deny-extended"),
        example_good: Some("fn fetch() { }  // Core tier, or remove --deny-extended"),
    },
    ExplainEntry {
        code: "W002",
        title: "unused import",
        explanation: "An import binding is never used. Remove it or run `nyra pkg prune`.",
        example_bad: Some("import \"stdlib/io.ny\"\nfn main() { print(1) }"),
        example_good: Some("fn main() { print(1) }"),
    },
    ExplainEntry {
        code: "W003",
        title: "unused variable",
        explanation: "A local binding is never read. Prefix with `_` or remove it.",
        example_bad: Some("fn main() {\n    let unused = 42\n    print(1)\n}"),
        example_good: Some("fn main() {\n    let _unused = 42\n    print(1)\n}"),
    },
    ExplainEntry {
        code: "P001",
        title: "anonymous object literal",
        explanation: "Nyra does not support JavaScript-style `{ key: value }` object literals. Declare a struct first.",
        example_bad: Some("let p = { name: \"Ada\" }"),
        example_good: Some("struct Person { name: string }\nlet p = Person { name: \"Ada\" }"),
    },
    ExplainEntry {
        code: "P002",
        title: "standalone block expression",
        explanation: "A bare `{ ... }` block was used where an expression was expected in an invalid context.",
        example_bad: Some("let x = { 1, 2 }"),
        example_good: Some("let x = { 1 + 2 }"),
    },
    ExplainEntry {
        code: "P003",
        title: "expected parameter name",
        explanation: "A function parameter list is missing a parameter name or has invalid syntax.",
        example_bad: Some("fn f(i32) {}"),
        example_good: Some("fn f(x: i32) {}"),
    },
    ExplainEntry {
        code: "P004",
        title: "expected `)` after parameters",
        explanation: "The parameter list of a function is not closed with `)`.",
        example_bad: Some("fn f(a: i32 { }"),
        example_good: Some("fn f(a: i32) { }"),
    },
    ExplainEntry {
        code: "P005",
        title: "expected `(` after function name",
        explanation: "A function declaration is missing `(` after its name.",
        example_bad: Some("fn main { }"),
        example_good: Some("fn main() { }"),
    },
    ExplainEntry {
        code: "P006",
        title: "invalid expression",
        explanation: "The parser could not build a valid expression. Often a cascade from an earlier syntax error.",
        example_bad: Some("let x = \nlet y = 1"),
        example_good: Some("let x = 1\nlet y = 2"),
    },
    ExplainEntry {
        code: "P007",
        title: "unexpected `{` in expression",
        explanation: "A `{` appeared where an expression was expected. Check struct literals vs blocks.",
        example_bad: Some("let x = if true { 1 } else { }"),
        example_good: Some("let x = if true { 1 } else { 0 }"),
    },
    ExplainEntry {
        code: "P008",
        title: "expected `}` to close block",
        explanation: "A block, function, or struct body is missing a closing `}`.",
        example_bad: Some("fn main() {\n    print(1)"),
        example_good: Some("fn main() {\n    print(1)\n}"),
    },
    ExplainEntry {
        code: "P009",
        title: "expected `{` to start block",
        explanation: "A function or control-flow construct is missing `{` to open its body.",
        example_bad: Some("fn main() print(1)"),
        example_good: Some("fn main() { print(1) }"),
    },
    ExplainEntry {
        code: "P010",
        title: "expected top-level item",
        explanation: "The parser found tokens that do not form a valid top-level declaration.",
        example_bad: Some("x = 1"),
        example_good: Some("fn main() { var x = 1 }"),
    },
    ExplainEntry {
        code: "P011",
        title: "expected `)` after arguments",
        explanation: "A function call or grouping is missing a closing `)`.",
        example_bad: Some("print(1"),
        example_good: Some("print(1)"),
    },
    ExplainEntry {
        code: "P012",
        title: "expected `=>` in arrow function",
        explanation: "An arrow function parameter list must be followed by `=>`.",
        example_bad: Some("let f = (x) { x + 1 }"),
        example_good: Some("let f = (x) => { x + 1 }"),
    },
    ExplainEntry {
        code: "P013",
        title: "expected `)`",
        explanation: "A parenthesized group or call is missing a closing `)`.",
        example_bad: Some("if (true { }"),
        example_good: Some("if true { }"),
    },
    ExplainEntry {
        code: "P014",
        title: "expected `]`",
        explanation: "An array literal or index expression is missing a closing `]`.",
        example_bad: Some("let a = [1, 2"),
        example_good: Some("let a = [1, 2]"),
    },
    ExplainEntry {
        code: "P099",
        title: "unexpected syntax",
        explanation: "An unclassified parser error. Fix earlier errors first; this may be a cascade.",
        example_bad: None,
        example_good: None,
    },
    ExplainEntry {
        code: "L001",
        title: "invalid token",
        explanation: "The lexer encountered a character or token sequence that is not valid Nyra syntax.",
        example_bad: Some("let x = @invalid"),
        example_good: Some("let x = 42"),
    },
];

/// Look up a stable diagnostic code (case-insensitive).
pub fn explain(code: &str) -> Option<&'static ExplainEntry> {
    let upper = code.to_ascii_uppercase();
    ENTRIES.iter().find(|e| e.code == upper)
}

/// All known stable diagnostic codes, sorted.
pub fn list_codes() -> Vec<&'static str> {
    ENTRIES.iter().map(|e| e.code).collect()
}

/// Format an explanation for terminal output.
pub fn format_explain(entry: &ExplainEntry) -> String {
    let mut out = format!("{} — {}\n\n{}\n", entry.code, entry.title, entry.explanation);
    if let Some(bad) = entry.example_bad {
        out.push_str("\nExample (incorrect):\n");
        out.push_str(bad);
        out.push('\n');
    }
    if let Some(good) = entry.example_good {
        out.push_str("\nExample (correct):\n");
        out.push_str(good);
        out.push('\n');
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn explain_known_code() {
        let e = explain("e003").expect("E003");
        assert_eq!(e.code, "E003");
        assert!(e.title.contains("type mismatch"));
    }

    #[test]
    fn explain_unknown_code() {
        assert!(explain("E999").is_none());
    }

    #[test]
    fn list_codes_non_empty() {
        assert!(list_codes().len() >= 20);
    }
}
