//! `nyra pkg prune` removes unused imports and prefixes unused locals.

mod common;

use common::{nyra_bin, workspace_root};
use std::process::Command;

#[test]
fn pkg_prune_check_reports_unused() {
    let dir = workspace_root().join("tests/fixtures/prune_unused");
    let output = Command::new(nyra_bin())
        .args(["pkg", "prune", "--check"])
        .current_dir(&dir)
        .output()
        .expect("nyra pkg prune --check");
    assert!(
        !output.status.success(),
        "expected check to fail when unused code exists"
    );
    let stderr = String::from_utf8_lossy(&output.stderr);
    assert!(
        stderr.contains("unused code found") || stderr.contains("prune check"),
        "stderr={stderr}"
    );
}

#[test]
fn pkg_prune_applies_fixes() {
    let dir = workspace_root().join("tests/fixtures/prune_unused");
    let main = dir.join("main.ny");
    let backup = std::fs::read_to_string(&main).expect("read main.ny");

    let output = Command::new(nyra_bin())
        .args(["pkg", "prune"])
        .current_dir(&dir)
        .output()
        .expect("nyra pkg prune");
    assert!(
        output.status.success(),
        "stderr={}",
        String::from_utf8_lossy(&output.stderr)
    );

    let pruned = std::fs::read_to_string(&main).expect("read pruned main.ny");
    assert!(!pruned.contains("import \"src/unused.ny\""));
    assert!(pruned.contains("let _dead = 99"));

    std::fs::write(&main, backup).expect("restore fixture");
}
