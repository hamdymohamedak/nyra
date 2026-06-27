mod common;

use common::compile_with;
use compiler::{CompileOptions, FeatureSet};

#[test]
fn feature_set_core_only_suppresses_spawn_warning() {
    let src = r#"fn main() { spawn { print(1) } }"#;
    let opts = CompileOptions {
        features: FeatureSet {
            spawn: false,
            ..FeatureSet::default()
        },
        ..Default::default()
    };
    let out = compile_with(src, "f.ny", &opts);
    assert!(
        !out.warnings.iter().any(|w| w.message.contains("spawn")),
        "spawn warning should be suppressed when feature disabled"
    );
}

#[test]
fn feature_set_default_spawn_stable_extended_v12() {
    let src = r#"fn main() { spawn { print(1) } }"#;
    let out = compile_with(src, "f.ny", &CompileOptions::default());
    assert!(
        out.warnings.is_empty(),
        "v1.2: spawn is Stable Extended, expected no W001: {:?}",
        out.warnings
    );
    assert!(out.llvm_ir.is_some(), "spawn should compile with default features");
}

#[test]
fn feature_set_core_only_all_extended_off() {
    let f = FeatureSet::core_only();
    assert!(!f.traits);
    assert!(!f.async_fns);
    assert!(!f.generics);
}
