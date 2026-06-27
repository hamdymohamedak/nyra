//! Conformance: games stdlib (CONF-GAME-*).

use crate::common::compile;

#[test]
fn conf_game_001_grid2d_flat_storage() {
    let out = compile(
        r#"fn grid_index(width: i32, row: i32, col: i32) -> i32 {
    return row * width + col
}
fn main() {
    let cells = Vec_i32_new()
    Vec_i32_push(cells, 0)
    Vec_i32_push(cells, 0)
    Vec_i32_push(cells, 0)
    Vec_i32_push(cells, 0)
    vec_i32_set(cells, grid_index(2, 0, 0), 1)
    print(Vec_i32_get(cells, 0))
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
}

#[test]
fn conf_game_002_vec_i32_set_runtime() {
    let out = compile(
        r#"extern fn vec_i32_set(v: ptr, i: i32, value: i32) -> void
fn main() {
    let v = Vec_i32_new()
    vec_i32_set(v, 0, 7)
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    let ir = out.llvm_ir.expect("ir");
    assert!(ir.contains("vec_i32_set"), "missing vec_i32_set in IR:\n{ir}");
}

#[test]
fn conf_game_003_ecs_store_shape() {
    let out = compile(
        r#"struct EcsStore_i32 {
    values: ptr
}
fn EcsStore_i32_new(cap: i32, fill: i32) -> EcsStore_i32 {
    let values = Vec_i32_new()
    let mut i = 0
    while i < cap {
        Vec_i32_push(values, fill)
        i = i + 1
    }
    return EcsStore_i32 { values: values }
}
fn main() {
    let hp = EcsStore_i32_new(4, -1)
    print(Vec_i32_len(hp.values))
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
}
