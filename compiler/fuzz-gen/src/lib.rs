//! Structured random Nyra program generator for fuzz / stress testing.
//!
//! Feeds libFuzzer and CI stress tests with malformed programs — unbalanced
//! delimiters, repeated keywords, token soup — to catch compiler panics.

const KEYWORDS: &[&str] = &[
    "let", "mut", "fn", "if", "else", "while", "break", "return", "import", "struct", "impl",
    "for", "const", "extern", "export", "enum", "match", "async", "await", "trait", "macro",
    "unsafe", "test", "spawn", "in", "as", "move", "clone", "defer", "dyn", "true", "false",
    "print", "module", "self", "inst", "no_std", "string", "bool", "void", "ptr",
];

const OPS: &[&str] = &[
    "+", "-", "*", "/", "%", "=", "==", "!=", "<", ">", "<=", ">=", "&&", "||", "!", "&", "|",
    "^", "<<", ">>", "..", "=>", "->", "++", "--", "@", "#", "::",
];

const DELIMS: &[char] = &['(', ')', '{', '}', '[', ']', ';', ',', ':', '.'];

const OPEN_DELIMS: &[char] = &['(', '(', '(', '{', '[', '<'];

const IMPORT_PATHS: &[&str] = &[
    "stdlib/testing.ny",
    "stdlib/__missing__.ny",
    "stdlib/fake_module.ny",
    "examples/syntax/hello.ny",
    "../escape.ny",
    "",
];

const STRING_ESCAPES: &[&str] = &[
    "\\n", "\\t", "\\r", "\\0", "\\\"", "\\\\", "\\x1b", "\\033", "\\x41", "\\u{2620}",
];

/// Deterministic PRNG seeded from fuzz input bytes.
pub struct FuzzRng {
    state: u64,
}

impl FuzzRng {
    pub fn new(seed: u64) -> Self {
        Self {
            state: seed.max(1),
        }
    }

    pub fn from_bytes(data: &[u8]) -> Self {
        let mut seed = 0xcbf29ce484222325u64;
        for (i, &b) in data.iter().enumerate() {
            seed ^= b as u64;
            seed = seed.wrapping_mul(0x100000001b3);
            if i >= 128 {
                break;
            }
        }
        Self::new(seed)
    }

    fn next_u32(&mut self) -> u32 {
        let mut x = self.state;
        x ^= x << 13;
        x ^= x >> 7;
        x ^= x << 17;
        self.state = x;
        x as u32
    }

    fn next_usize(&mut self, max: usize) -> usize {
        if max == 0 {
            0
        } else {
            (self.next_u32() as usize) % max
        }
    }

    pub fn gen_bool(&mut self) -> bool {
        self.next_u32() % 2 == 0
    }

    pub fn choose<'a, T>(&mut self, slice: &'a [T]) -> &'a T {
        &slice[self.next_usize(slice.len())]
    }
}

/// Generate a random (usually invalid) Nyra program from fuzz bytes.
pub fn generate(data: &[u8]) -> String {
    let mut rng = FuzzRng::from_bytes(data);
    match rng.next_u32() % 11 {
        0 => gen_raw_utf8(data),
        1 => gen_token_soup(&mut rng),
        2 => gen_broken_main(&mut rng),
        3 => gen_repeated_keyword(&mut rng),
        4 => gen_unbalanced(&mut rng),
        5 => gen_mixed_fragments(&mut rng),
        6 => gen_type_noise(&mut rng),
        7 => gen_chaos(&mut rng),
        8 => gen_imports(&mut rng),
        9 => gen_string_escapes(&mut rng),
        _ => gen_valid_skeleton(&mut rng),
    }
}

fn gen_raw_utf8(data: &[u8]) -> String {
    std::str::from_utf8(data)
        .map(str::to_owned)
        .unwrap_or_else(|_| String::from_utf8_lossy(data).into_owned())
}

fn append_token(rng: &mut FuzzRng, out: &mut String) {
    match rng.next_u32() % 6 {
        0 => {
            out.push_str(*rng.choose(KEYWORDS));
            out.push(' ');
        }
        1 => out.push_str(*rng.choose(OPS)),
        2 => out.push(*rng.choose(DELIMS)),
        3 => {
            out.push('_');
            out.push_str(&format!("{}", rng.next_u32() % 10_000));
            out.push(' ');
        }
        4 => {
            out.push_str(&format!("{}", rng.next_u32() % 10_000));
            out.push(' ');
        }
        _ => {
            out.push('"');
            let len = 1 + rng.next_usize(12);
            for _ in 0..len {
                let c = (b'a' + (rng.next_u32() % 26) as u8) as char;
                out.push(c);
            }
            out.push('"');
            out.push(' ');
        }
    }
}

fn gen_token_soup(rng: &mut FuzzRng) -> String {
    let n = 5 + rng.next_usize(60);
    let mut out = String::with_capacity(n * 8);
    for _ in 0..n {
        append_token(rng, &mut out);
    }
    out
}

fn gen_broken_main(rng: &mut FuzzRng) -> String {
    let mut out = String::from("fn main() { ");
    let body_len = 8 + rng.next_usize(80);
    for _ in 0..body_len {
        append_token(rng, &mut out);
    }
    if rng.gen_bool() {
        out.push('}');
    }
    out
}

fn gen_repeated_keyword(rng: &mut FuzzRng) -> String {
    let kw = *rng.choose(KEYWORDS);
    let n = 2 + rng.next_usize(24);
    let mut out = String::new();
    for i in 0..n {
        if i > 0 {
            out.push(' ');
        }
        out.push_str(kw);
    }
    out
}

fn gen_unbalanced(rng: &mut FuzzRng) -> String {
    let mut out = String::from("fn main() { ");
    if rng.gen_bool() {
        out.push_str("if ");
    }
    let n = 3 + rng.next_usize(40);
    for _ in 0..n {
        out.push(*rng.choose(OPEN_DELIMS));
    }
    if rng.gen_bool() {
        append_token(rng, &mut out);
    }
    out
}

fn gen_mixed_fragments(rng: &mut FuzzRng) -> String {
    let mut out = String::new();
    let frags = [
        "fn main() {",
        "let let let let",
        "if (((({",
        "struct S { x: i32",
        "match x {",
        "import \"",
        "fn f(a: i32, b: string) -> bool { return",
        "enum E { A, B",
        "impl T for U {",
        "async fn g() { await",
        "unsafe { ptr ",
        "#[derive(",
    ];
    let count = 1 + rng.next_usize(4);
    for i in 0..count {
        if i > 0 {
            out.push('\n');
        }
        out.push_str(*rng.choose(&frags));
        if rng.gen_bool() {
            let extra = 2 + rng.next_usize(8);
            for _ in 0..extra {
                append_token(rng, &mut out);
            }
        }
    }
    out
}

fn gen_type_noise(rng: &mut FuzzRng) -> String {
    let types = ["i8", "i16", "i32", "i64", "u8", "u16", "u32", "u64", "f64", "bool", "string", "void", "ptr"];
    let mut out = String::from("fn main() { let x: ");
    let depth = 1 + rng.next_usize(6);
    for _ in 0..depth {
        match rng.next_u32() % 4 {
            0 => out.push_str(*rng.choose(&types)),
            1 => out.push('['),
            2 => out.push('<'),
            _ => out.push('('),
        }
    }
    out.push_str(" = ");
    append_token(rng, &mut out);
    if rng.gen_bool() {
        out.push('}');
    }
    out
}

fn gen_chaos(rng: &mut FuzzRng) -> String {
    let mut out = gen_broken_main(rng);
    if rng.gen_bool() {
        out.push('\n');
        out.push_str(&gen_repeated_keyword(rng));
    }
    if rng.gen_bool() {
        out.push('\n');
        out.push_str(&gen_unbalanced(rng));
    }
    out
}

fn gen_imports(rng: &mut FuzzRng) -> String {
    let mut out = String::new();
    let imports = 1 + rng.next_usize(3);
    for i in 0..imports {
        if i > 0 {
            out.push('\n');
        }
        out.push_str("import \"");
        out.push_str(*rng.choose(IMPORT_PATHS));
        out.push('"');
        if rng.gen_bool() {
            append_token(rng, &mut out);
        }
    }
    out.push('\n');
    out.push_str(&gen_broken_main(rng));
    out
}

fn gen_string_escapes(rng: &mut FuzzRng) -> String {
    let mut out = String::from("fn main() { let s = \"");
    let parts = 1 + rng.next_usize(8);
    for i in 0..parts {
        if rng.gen_bool() {
            out.push_str(*rng.choose(STRING_ESCAPES));
        } else {
            let c = (b'a' + (rng.next_u32() % 26) as u8) as char;
            out.push(c);
        }
        if i + 1 < parts && rng.gen_bool() {
            out.push_str("\\");
        }
    }
    out.push('"');
    if rng.gen_bool() {
        out.push_str(" print(s) ");
    }
    append_token(rng, &mut out);
    if rng.gen_bool() {
        out.push('}');
    }
    out
}

fn gen_valid_skeleton(rng: &mut FuzzRng) -> String {
    let id = format!("v{}", rng.next_u32() % 1000);
    let exprs = ["1", "true", "false", "\"hi\"", "x + 1", "x * 2", "@bad", "1_000_000"];
    let expr = *rng.choose(&exprs);
    let mut out = format!(
        "fn main() {{\n    let mut {id} = 0\n    let {id} = {expr}\n    if {id} > 0 {{\n        print({id})\n    }}\n"
    );
    if rng.gen_bool() {
        out.push_str("    while true { break }\n");
    }
    if rng.gen_bool() {
        out.push_str("    match x { _ => { } }\n");
    }
    if rng.gen_bool() {
        append_token(rng, &mut out);
    }
    if rng.gen_bool() {
        out.push('}');
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn generates_non_empty_for_any_input() {
        for i in 0..64u64 {
            let data = i.to_le_bytes();
            let src = generate(&data);
            assert!(!src.is_empty());
        }
    }

    #[test]
    fn includes_known_patterns() {
        let mut saw_repeated = false;
        let mut saw_unbalanced = false;
        for i in 0..500u64 {
            let data = (i.wrapping_mul(0x9e3779b97f4a7c15)).to_le_bytes();
            let src = generate(&data);
            if src.contains("let let") || src.matches("let").count() >= 3 {
                saw_repeated = true;
            }
            if src.contains("(((") || src.contains("if ((((") {
                saw_unbalanced = true;
            }
        }
        assert!(saw_repeated, "expected repeated-keyword patterns");
        assert!(saw_unbalanced, "expected unbalanced-delimiter patterns");
    }

    #[test]
    fn generates_import_and_string_patterns() {
        let mut saw_import = false;
        let mut saw_escape = false;
        for i in 0..800u64 {
            let data = (i.wrapping_mul(0x517cc1b727220a95)).to_le_bytes();
            let src = generate(&data);
            if src.contains("import \"") {
                saw_import = true;
            }
            if src.contains("\\n") || src.contains("\\x") || src.contains("\\u{") {
                saw_escape = true;
            }
        }
        assert!(saw_import, "expected import patterns");
        assert!(saw_escape, "expected string escape patterns");
    }
}
