//! CLI wrapper for `nyra test` on native test files.

mod common;

use common::{nyra_bin, workspace_root};
use std::process::Command;

#[test]
fn nyra_test_math_suite() {
    let dir = workspace_root().join("tests/nyra");
    let output = Command::new(nyra_bin())
        .arg("test")
        .arg(&dir)
        .output()
        .expect("nyra test");
    assert!(
        output.status.success(),
        "stderr={}\nstdout={}",
        String::from_utf8_lossy(&output.stderr),
        String::from_utf8_lossy(&output.stdout)
    );
    let stdout = String::from_utf8_lossy(&output.stdout);
    assert!(stdout.contains("tests passed") || stdout.contains("PASS"));
}

#[test]
fn nyra_test_smoke_example() {
    let path = workspace_root().join("examples/smoke_test_test.ny");
    let output = Command::new(nyra_bin())
        .arg("test")
        .arg(&path)
        .output()
        .expect("nyra test smoke");
    assert!(output.status.success(), "{}", String::from_utf8_lossy(&output.stderr));
}
