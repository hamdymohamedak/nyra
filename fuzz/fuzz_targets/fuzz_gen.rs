#![no_main]

use compiler::{CompileOptions, CompileStage, Compiler};
use fuzz_gen::generate;
use libfuzzer_sys::fuzz_target;

// Grammar-aware fuzz: generates malformed Nyra programs and runs the full
// compile pipeline (lex → parse → typecheck → borrowck). Any panic = bug.
fuzz_target!(|data: &[u8]| {
    let src = generate(data);
    let opts = CompileOptions {
        stop_after: Some(CompileStage::Borrow),
        ..Default::default()
    };
    let _ = Compiler::compile_source(&src, "fuzz.ny", &opts);
});
