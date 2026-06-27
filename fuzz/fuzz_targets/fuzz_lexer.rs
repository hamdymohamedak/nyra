#![no_main]

use libfuzzer_sys::fuzz_target;

fn lossy_utf8(data: &[u8]) -> std::borrow::Cow<'_, str> {
    std::str::from_utf8(data).map(std::borrow::Cow::Borrowed).unwrap_or_else(|_| {
        String::from_utf8_lossy(data)
    })
}

fuzz_target!(|data: &[u8]| {
    let s = lossy_utf8(data);
    let (_tokens, _errs) = lexer::Lexer::new(s.as_ref(), "fuzz.ny").tokenize();
});
