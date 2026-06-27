//! Fuzz stress test — runs thousands of generated programs through the compiler.
//! Catches panics without requiring libFuzzer / cargo-fuzz.
//!
//! Override iteration count: `NYRA_FUZZ_ITERS=10000 cargo test -p compiler fuzz_stress`

use compiler::{CompileOptions, CompileStage, Compiler};
use fuzz_gen::generate;

fn fuzz_iterations(default: u64, env_key: &str) -> u64 {
    std::env::var(env_key)
        .ok()
        .and_then(|s| s.parse().ok())
        .unwrap_or(default)
}

fn run_fuzz_batch(iters: u64, opts: &CompileOptions, label: &str) {
    for i in 0..iters {
        let len = 8 + (i as usize % 256);
        let mut data = vec![0u8; len];
        for (j, b) in data.iter_mut().enumerate() {
            *b = (i
                .wrapping_mul(7919)
                .wrapping_add(j as u64)
                .wrapping_mul(0x9e3779b97f4a7c15)
                % 256) as u8;
        }
        let src = generate(&data);
        let result = std::panic::catch_unwind(|| Compiler::compile_source(&src, "fuzz.ny", opts));
        assert!(
            result.is_ok(),
            "{label}: compiler panicked on fuzz input #{i} (len={len}): {:?}",
            &src[..src.len().min(200)]
        );
    }
}

#[test]
fn fuzz_stress_no_panics() {
    let iters = fuzz_iterations(2_000, "NYRA_FUZZ_ITERS");
    let opts = CompileOptions {
        stop_after: Some(CompileStage::Borrow),
        ..Default::default()
    };
    run_fuzz_batch(iters, &opts, "borrowck");
}

#[test]
fn fuzz_stress_codegen_no_panics() {
    let iters = fuzz_iterations(500, "NYRA_FUZZ_CODEGEN_ITERS");
    let opts = CompileOptions {
        stop_after: Some(CompileStage::Codegen),
        ..Default::default()
    };
    run_fuzz_batch(iters, &opts, "codegen");
}

#[test]
fn fuzz_stress_known_crash_seeds() {
    let seeds: &[&[u8]] = &[
        b"fn main() { if (((({",
        b"let let let let",
        b"fn main() { let x = @1 }",
        b"fn struct enum match import let mut async await",
        b"888888888888888888888888",
        b"import \"stdlib/testing.ny\"\nfn main() { print(1) }",
        b"fn main() { let s = \"\\n\\x1b\\u{2620}\" }",
    ];
    let stages = [
        CompileStage::Borrow,
        CompileStage::Codegen,
    ];

    for stage in stages {
        let opts = CompileOptions {
            stop_after: Some(stage),
            ..Default::default()
        };
        for (i, seed) in seeds.iter().enumerate() {
            let src = generate(seed);
            let result =
                std::panic::catch_unwind(|| Compiler::compile_source(&src, "fuzz.ny", &opts));
            assert!(
                result.is_ok(),
                "compiler panicked on generated seed #{i} at {stage:?}: {src:?}"
            );
            if let Ok(raw) = std::str::from_utf8(seed) {
                let result =
                    std::panic::catch_unwind(|| Compiler::compile_source(raw, "fuzz.ny", &opts));
                assert!(
                    result.is_ok(),
                    "compiler panicked on raw seed #{i} at {stage:?}: {raw:?}"
                );
            }
        }
    }
}
