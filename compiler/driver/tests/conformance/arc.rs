//! Conformance tests: Arc shared ownership (CONF-ARC-*).

use crate::common::{assert_ir_patterns, compile, compile_file_rel};

#[test]
fn conf_arc_001_clone_get_i32() {
    let out = compile(
        r#"extern fn arc_alloc_i32(value: i32) -> ptr
extern fn arc_inc(handle: ptr) -> void
extern fn arc_dec(handle: ptr) -> void
extern fn arc_get_i32(handle: ptr) -> i32

struct Arc_i32 Send Sync {
    handle: ptr
}

fn Arc_new_i32(value: i32) -> Arc_i32 {
    return Arc_i32 { handle: arc_alloc_i32(value) }
}

fn Arc_clone_i32(arc: Arc_i32) -> Arc_i32 {
    arc_inc(arc.handle)
    return arc
}

fn Arc_get_i32(arc: Arc_i32) -> i32 {
    return arc_get_i32(arc.handle)
}

fn main() {
    let a = Arc_new_i32(9)
    let b = Arc_clone_i32(a)
    print(Arc_get_i32(b))
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    assert!(out.llvm_ir.is_some());
}

#[test]
fn conf_arc_002_generic_arc_string_drop() {
    let out = compile(
        r#"extern fn arc_alloc_string(value: string) -> ptr
extern fn arc_inc(handle: ptr) -> void
extern fn arc_dec_string(handle: ptr) -> void
extern fn arc_get_string(handle: ptr) -> string

struct Arc__string Send Sync {
    handle: ptr
}

fn Arc_from_string(value: string) -> Arc__string {
    return Arc__string { handle: arc_alloc_string(value) }
}

fn Arc_clone_string(arc: Arc__string) -> Arc__string {
    arc_inc(arc.handle)
    return arc
}

impl Drop for Arc__string {
    fn drop(self) -> void {
        arc_dec_string(self.handle)
    }
}

fn main() {
    let root = Arc_from_string("shared")
    let copy = Arc_clone_string(root)
    print(arc_get_string(copy.handle))
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    assert!(out.borrow_errors.is_empty(), "{:?}", out.borrow_errors);
    let ir = out.llvm_ir.expect("ir");
    assert_ir_patterns(&ir, &["arc_inc", "arc_dec_string"], &[]);
}

#[test]
fn conf_arc_003_graph_arc_smoke_compiles() {
    let out = compile_file_rel("examples/graph_arc_smoke.ny");
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    assert!(out.borrow_errors.is_empty(), "{:?}", out.borrow_errors);
    let ir = out.llvm_ir.expect("ir");
    assert_ir_patterns(&ir, &["arc_alloc_string", "arc_inc"], &[]);
}
