//! File-based compile test suite (`tests/suite/`).

mod common;

use std::path::PathBuf;

use compiletest::{run_suite_labeled, run_suite_labeled_excluding, SuiteMode};

fn suite_root() -> PathBuf {
    common::workspace_root().join("tests/suite")
}

fn filter_from_env() -> String {
    std::env::var("NYRA_SUITE_FILTER").unwrap_or_default()
}

fn update_from_env() -> bool {
    std::env::var("NYRA_SUITE_UPDATE").is_ok()
}

/// Sharded subtrees have dedicated `suite_*_generated_*` targets for CI parallelism.
const EXCLUDE_GENERATED: &[&str] = &["generated"];
const EXCLUDE_FAIL_SHARDS: &[&str] = &["generated", "regression"];

fn run_subsuite(label: &str, root: PathBuf, mode: SuiteMode) {
    if !root.exists() {
        return;
    }
    let result = run_suite_labeled(&root, mode, &filter_from_env(), update_from_env(), label);
    result.assert_all_passed();
}

fn run_subsuite_excluding(label: &str, root: PathBuf, mode: SuiteMode, exclude: &[&str]) {
    if !root.exists() {
        return;
    }
    let result = run_suite_labeled_excluding(
        &root,
        mode,
        &filter_from_env(),
        update_from_env(),
        label,
        exclude,
    );
    result.assert_all_passed();
}

#[test]
fn suite_pass() {
    run_subsuite_excluding("pass", suite_root().join("pass"), SuiteMode::Pass, EXCLUDE_GENERATED);
}

#[test]
fn suite_fail() {
    run_subsuite_excluding(
        "fail",
        suite_root().join("fail"),
        SuiteMode::Fail,
        EXCLUDE_FAIL_SHARDS,
    );
}

#[test]
fn suite_run() {
    run_subsuite_excluding("run", suite_root().join("run"), SuiteMode::Run, EXCLUDE_GENERATED);
}

// Sharded targets for CI parallelism (cargo runs these concurrently).
#[test]
fn suite_pass_generated_types() {
    run_subsuite(
        "pass/generated/types",
        suite_root().join("pass/generated/types"),
        SuiteMode::Pass,
    );
}

#[test]
fn suite_pass_generated_borrow() {
    run_subsuite(
        "pass/generated/borrow",
        suite_root().join("pass/generated/borrow"),
        SuiteMode::Pass,
    );
}

#[test]
fn suite_pass_generated_lexer() {
    run_subsuite(
        "pass/generated/lexer",
        suite_root().join("pass/generated/lexer"),
        SuiteMode::Pass,
    );
}

#[test]
fn suite_pass_generated_parser() {
    run_subsuite(
        "pass/generated/parser",
        suite_root().join("pass/generated/parser"),
        SuiteMode::Pass,
    );
}

#[test]
fn suite_fail_generated_types() {
    run_subsuite(
        "fail/generated/types",
        suite_root().join("fail/generated/types"),
        SuiteMode::Fail,
    );
}

#[test]
fn suite_fail_generated_borrow() {
    run_subsuite(
        "fail/generated/borrow",
        suite_root().join("fail/generated/borrow"),
        SuiteMode::Fail,
    );
}

#[test]
fn suite_fail_generated_lexer() {
    run_subsuite(
        "fail/generated/lexer",
        suite_root().join("fail/generated/lexer"),
        SuiteMode::Fail,
    );
}

#[test]
fn suite_fail_generated_parser() {
    run_subsuite(
        "fail/generated/parser",
        suite_root().join("fail/generated/parser"),
        SuiteMode::Fail,
    );
}

#[test]
fn suite_fail_regression() {
    run_subsuite(
        "fail/regression",
        suite_root().join("fail/regression"),
        SuiteMode::Fail,
    );
}

#[test]
fn suite_run_generated_arith() {
    run_subsuite(
        "run/generated/arith",
        suite_root().join("run/generated/arith"),
        SuiteMode::Run,
    );
}

#[test]
fn suite_run_generated_cmp() {
    run_subsuite(
        "run/generated/cmp",
        suite_root().join("run/generated/cmp"),
        SuiteMode::Run,
    );
}

#[test]
fn suite_run_generated_control() {
    run_subsuite(
        "run/generated/control",
        suite_root().join("run/generated/control"),
        SuiteMode::Run,
    );
}

#[test]
fn suite_pass_generated_stdlib() {
    run_subsuite(
        "pass/generated/stdlib",
        suite_root().join("pass/generated/stdlib"),
        SuiteMode::Pass,
    );
}

#[test]
fn suite_pass_generated_generics() {
    run_subsuite(
        "pass/generated/generics",
        suite_root().join("pass/generated/generics"),
        SuiteMode::Pass,
    );
}

#[test]
fn suite_pass_generated_match() {
    run_subsuite(
        "pass/generated/match",
        suite_root().join("pass/generated/match"),
        SuiteMode::Pass,
    );
}

#[test]
fn suite_fail_generated_stderr() {
    run_subsuite(
        "fail/generated/stderr",
        suite_root().join("fail/generated/stderr"),
        SuiteMode::Fail,
    );
}

#[test]
fn suite_projects_pass() {
    run_subsuite(
        "projects/pass",
        suite_root().join("projects/pass"),
        SuiteMode::Pass,
    );
}

#[test]
fn suite_projects_fail() {
    run_subsuite(
        "projects/fail",
        suite_root().join("projects/fail"),
        SuiteMode::Fail,
    );
}

#[test]
fn suite_projects_run() {
    run_subsuite(
        "projects/run",
        suite_root().join("projects/run"),
        SuiteMode::Run,
    );
}

#[test]
fn suite_run_generated_stdlib() {
    run_subsuite(
        "run/generated/stdlib",
        suite_root().join("run/generated/stdlib"),
        SuiteMode::Run,
    );
}

#[test]
fn suite_pass_generated_stdlib_imports() {
    run_subsuite(
        "pass/generated/stdlib_import",
        suite_root().join("pass/generated/stdlib_import"),
        SuiteMode::Pass,
    );
}

#[test]
fn suite_pass_generated_types_i64() {
    run_subsuite(
        "pass/generated/types_i64",
        suite_root().join("pass/generated/types_i64"),
        SuiteMode::Pass,
    );
}

#[test]
fn suite_pass_generated_types_f64() {
    run_subsuite(
        "pass/generated/types_f64",
        suite_root().join("pass/generated/types_f64"),
        SuiteMode::Pass,
    );
}

#[test]
fn suite_pass_generated_fn_grid() {
    run_subsuite(
        "pass/generated/fn_grid",
        suite_root().join("pass/generated/fn_grid"),
        SuiteMode::Pass,
    );
}

#[test]
fn suite_fail_generated_stderr_full() {
    run_subsuite(
        "fail/generated/stderr_full",
        suite_root().join("fail/generated/stderr_full"),
        SuiteMode::Fail,
    );
}

#[test]
fn suite_fail_fuzz_regression() {
    run_subsuite(
        "fail/regression/fuzz",
        suite_root().join("fail/regression/fuzz"),
        SuiteMode::Fail,
    );
}

#[test]
fn suite_fail_stdlib_import() {
    run_subsuite(
        "fail/generated/stdlib_import",
        suite_root().join("fail/generated/stdlib_import"),
        SuiteMode::Fail,
    );
}

#[test]
fn suite_run_generated_print() {
    run_subsuite(
        "run/generated/print",
        suite_root().join("run/generated/print"),
        SuiteMode::Run,
    );
}

#[test]
fn suite_run_generated_arith_i64() {
    run_subsuite(
        "run/generated/arith_i64",
        suite_root().join("run/generated/arith_i64"),
        SuiteMode::Run,
    );
}

#[test]
fn suite_run_generated_for_nested() {
    run_subsuite(
        "run/generated/for_nested",
        suite_root().join("run/generated/for_nested"),
        SuiteMode::Run,
    );
}

#[test]
fn suite_run_generated_cmp_i64() {
    run_subsuite(
        "run/generated/cmp_i64",
        suite_root().join("run/generated/cmp_i64"),
        SuiteMode::Run,
    );
}

#[test]
fn suite_run_generated_cmp_f64() {
    run_subsuite(
        "run/generated/cmp_f64",
        suite_root().join("run/generated/cmp_f64"),
        SuiteMode::Run,
    );
}

#[test]
fn suite_minimum_count() {
    let root = suite_root();
    if !root.exists() {
        return;
    }
    let total = ["pass", "fail", "run"]
        .iter()
        .map(|d| compiletest::collect_tests(&root.join(d), "").len())
        .sum::<usize>()
        + ["projects/pass", "projects/fail", "projects/run"]
            .iter()
            .map(|d| compiletest::collect_tests(&root.join(d), "").len())
            .sum::<usize>();
    let baseline_path = root.join(".count-baseline");
    let min = baseline_path
        .exists()
        .then(|| std::fs::read_to_string(&baseline_path).ok())
        .flatten()
        .and_then(|s| s.trim().parse().ok())
        .unwrap_or(1500);
    assert!(
        total >= min,
        "expected at least {min} suite tests, found {total}"
    );
}
