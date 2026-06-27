#![no_main]

use compiler::{CompileOptions, CompileStage, Compiler};
use fuzz_gen::generate;
use libfuzzer_sys::fuzz_target;

// Full pipeline through LLVM codegen (lex → parse → typecheck → borrowck → codegen).
fuzz_target!(|data: &[u8]| {
    let src = generate(data);
    let opts = CompileOptions {
        stop_after: Some(CompileStage::Codegen),
        ..Default::default()
    };
    let _ = Compiler::compile_source(&src, "fuzz.ny", &opts);
});
