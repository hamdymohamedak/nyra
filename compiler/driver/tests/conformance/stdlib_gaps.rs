//! Conformance: stdlib gaps fixed in v1.18.0 (CONF-STD-*).

use crate::common::compile;

#[test]
fn conf_std_001_sqlite_rowset_symbols() {
    let out = compile(
        r#"extern fn sqlite_open(path: string) -> ptr
extern fn sqlite_query_rows(handle: ptr, sql: string) -> ptr
extern fn sqlite_rowset_rows(rowset: ptr) -> i32
fn main() {
    let db = sqlite_open(":memory:")
    let rs = sqlite_query_rows(db, "SELECT 1")
    print(sqlite_rowset_rows(rs))
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    let ir = out.llvm_ir.expect("ir");
    assert!(ir.contains("sqlite_rowset_rows"), "missing rowset in IR:\n{ir}");
}

#[test]
fn conf_std_002_fsync_file() {
    let out = compile(
        r#"extern fn fsync_file(path: string) -> i32
fn main() {
    print(fsync_file("x"))
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    let ir = out.llvm_ir.expect("ir");
    assert!(ir.contains("fsync_file"), "missing fsync in IR:\n{ir}");
}

#[test]
fn conf_std_003_btree_map_str_str() {
    let out = compile(
        r#"struct BTreeMap_str_str {
    keys: StrVec
    values: StrVec
}
fn BTreeMap_str_str_new() {
    return BTreeMap_str_str { keys: StrVec_new(), values: StrVec_new() }
}
fn main() {
    let m = BTreeMap_str_str_new()
    print(m.keys.len())
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
}
