//! Unit tests for LLVM IR emission patterns.

use std::io::Write;
use std::process::{Command, Stdio};

use codegen::Codegen;
use lexer::Lexer;
use parser::Parser;

fn compile_ir(src: &str) -> String {
    let (tokens, _) = Lexer::new(src, "codegen_test.ny").tokenize();
    let (program, _) = Parser::new(tokens).parse();
    let mut cg = Codegen::new("codegen_test.ny");
    cg.compile_program(&program)
}

/// Run `opt -verify-each` when LLVM is on PATH (skipped otherwise).
fn opt_verify_module(ir: &str) -> Result<(), String> {
    let opt = match which_opt() {
        Some(p) => p,
        None => return Ok(()),
    };
    let mut child = Command::new(opt)
        .args(["-verify-each", "-O3", "-o", "/dev/null", "-"])
        .stdin(Stdio::piped())
        .stdout(Stdio::null())
        .stderr(Stdio::piped())
        .spawn()
        .map_err(|e| e.to_string())?;
    child
        .stdin
        .take()
        .ok_or_else(|| "opt stdin".to_string())?
        .write_all(ir.as_bytes())
        .map_err(|e| e.to_string())?;
    let out = child.wait_with_output().map_err(|e| e.to_string())?;
    if out.status.success() {
        Ok(())
    } else {
        Err(String::from_utf8_lossy(&out.stderr).into_owned())
    }
}

fn which_opt() -> Option<String> {
    for name in ["opt", "llvm-opt"] {
        if Command::new(name).arg("--version").output().is_ok() {
            return Some(name.into());
        }
    }
    None
}

/// Body of `@main` after the opening `{` (Nyra `fn main()` lowers to C `main(argc, argv)`).
fn main_fn_body(ir: &str) -> &str {
    ir.split("define i32 @main")
        .nth(1)
        .and_then(|rest| rest.split_once('{').map(|(_, body)| body))
        .unwrap_or("")
}

#[test]
fn hello_emits_main_and_printf() {
    let ir = compile_ir(
        r#"fn main() {
    print("hi")
}"#,
    );
    assert!(ir.contains("@main") || ir.contains("define void @main") || ir.contains("define i32 @main"));
    assert!(ir.contains("@puts") || ir.contains("@printf"));
}

#[test]
fn static_string_print_uses_puts() {
    let ir = compile_ir(
        r#"fn main() {
    print("Hello Nyra")
}"#,
    );
    assert!(ir.contains("call i32 @puts"), "static print should use puts:\n{ir}");
    assert!(
        !ir.contains("call i32 (ptr, ...) @printf"),
        "single static string should not call printf:\n{ir}"
    );
}

#[test]
fn mod_by_positive_const_non_negative_uses_urem() {
    let ir = compile_ir(
        r#"fn main() {
    mut i = 0
    mut acc = 0
    while i < 100 {
        acc = (acc + (i % 997)) % 997
        i = i + 1
    }
    print(acc)
}"#,
    );
    assert!(ir.contains("urem i32"), "expected urem for non-negative mod chain:\n{ir}");
    assert!(
        !ir.contains("srem i32"),
        "non-negative mod chain must not emit signed remainder:\n{ir}"
    );
}

#[test]
fn grouped_add_mod_uses_urem() {
    let ir = compile_ir(
        r#"fn main() {
    mut acc = 0
    mut i = 0
    while i < 10 {
        acc = ((acc + (i % 997)) % 997)
        i = i + 1
    }
    print(acc)
}"#,
    );
    assert!(
        !ir.contains("srem i32"),
        "parenthesized non-negative mod chain must use urem:\n{ir}"
    );
}

#[test]
fn spawn_while_loop_has_no_latch_block() {
    let ir = compile_ir(
        r#"allow_extended
extern fn channel_new() -> ptr
extern fn channel_send(ch: ptr, value: i32) -> void
extern fn blackbox_i32(x: i32) -> i32
fn main() {
    let ch = channel_new()
    spawn {
        let mut j = 0
        while j < 4 {
            channel_send(ch, j)
            j = j + 1
        }
    }
    print(blackbox_i32(0))
}"#,
    );
    assert!(
        !ir.contains("loop.latch"),
        "spawn while must patch phis in nested emit_buf:\n{ir}"
    );
    opt_verify_module(&ir).expect("spawn while IR should pass llvm opt");
}

#[test]
fn nested_spawn_ir_valid() {
    let ir = compile_ir(
        r#"fn outer() {
    spawn {
        spawn {
            print(1)
        }
    }
}
fn main() {
    outer()
}"#,
    );
    assert!(
        ir.contains("define void @__spawn_"),
        "nested spawn body fn expected:\n{ir}"
    );
    assert!(
        !ir.contains("ret void\n}\n  %spawn.cap"),
        "outer fn must not leak IR after nested spawn close:\n{ir}"
    );
    opt_verify_module(&ir).expect("nested spawn IR should pass llvm opt");
}

#[test]
fn spawn_array_capture_copies_full_cap() {
    let ir = compile_ir(
        r#"fn walk(arr: [i32; 2]) {
    spawn {
        print(arr[0])
    }
}
fn main() {
    let a = [1, 2]
    walk(a)
}"#,
    );
    assert!(
        ir.contains("call ptr @malloc(i64 8)"),
        "spawn cap with [2 x i32] field must allocate 8 bytes (not 4):\n{ir}"
    );
    opt_verify_module(&ir).expect("spawn array capture IR should pass llvm opt");
}

#[test]
fn while_with_if_in_body_phi_backedge_from_merge() {
    let ir = compile_ir(
        r#"extern fn blackbox_i32(x: i32) -> i32
fn main() {
    mut acc = 0
    let n = 8
    mut i = 0
    while i < n {
        if i % 2 == 0 {
            acc = acc + i
        } else {
            acc = acc + 1
        }
        i = i + 1
    }
    print(blackbox_i32(acc))
}"#,
    );
    let body = main_fn_body(&ir);
    assert!(
        !body.contains("loop.latch"),
        "while loops should not use a latch block:\n{body}"
    );
    // Loop-carried phis must back-edge from the merge block after if/else, not while.body.
    assert!(
        !body.contains("[%, %while.body"),
        "loop phi must not list while.body as back-edge predecessor when body contains if:\n{body}"
    );
    opt_verify_module(&ir).expect("LLVM opt should accept IR with if inside while body");
}

#[test]
fn for_range_loop_has_no_latch_block() {
    let ir = compile_ir(
        r#"fn main() {
    mut banner = 0
    for i in 0..3 {
        banner = banner + i
    }
    print(banner)
}"#,
    );
    let body = main_fn_body(&ir);
    assert!(
        !body.contains("loop.latch"),
        "for-range loops should back-edge from body to header directly:\n{body}"
    );
    assert!(body.contains("for.body"), "expected for.body block:\n{body}");
}

#[test]
fn cpu_bound_loop_has_no_latch_block() {
    let ir = compile_ir(
        r#"extern fn blackbox_i32(x: i32) -> i32
fn main() {
    mut acc = 0
    let n = 120000000
    mut i = 0
    while i < n {
        let term = (i % 997) * 31
        acc = (acc + term) % 997
        i = i + 1
    }
    print(blackbox_i32(acc))
}"#,
    );
    let body = main_fn_body(&ir);
    assert!(
        !body.contains("loop.latch"),
        "while loops should back-edge from body to header directly:\n{body}"
    );
    assert!(
        body.contains("while.body"),
        "expected while.body block:\n{body}"
    );
}

#[test]
fn cpu_bound_mod_chain_uses_urem_only() {
    let ir = compile_ir(
        r#"extern fn blackbox_i32(x: i32) -> i32
fn main() {
    mut acc = 0
    let n = 120000000
    mut i = 0
    while i < n {
        let term = (i % 997) * 31
        acc = (acc + term) % 997
        i = i + 1
    }
    print(blackbox_i32(acc))
}"#,
    );
    assert!(
        !ir.contains("srem i32"),
        "cpu_bound-style mod chain must use unsigned remainder throughout:\n{ir}"
    );
    assert_eq!(
        ir.matches("urem i32").count(),
        2,
        "expected two urem per iteration (i and acc):\n{ir}"
    );
}

#[test]
fn add_emits_llvm_add_i32() {
    let ir = compile_ir(
        r#"fn main() {
    let x = 1 + 2
    print(x)
}"#,
    );
    assert!(ir.contains("add i32"));
}

#[test]
fn immutable_local_avoids_alloca() {
    let ir = compile_ir(
        r#"fn main() {
    let x = 10
    print(x)
}"#,
    );
    assert!(!ir.contains("alloca"), "immutable let should use SSA:\n{ir}");
}

#[test]
fn mutable_scalar_uses_ssa_not_alloca() {
    let ir = compile_ir(
        r#"fn main() {
    let mut n = 0
    n = 1
    print(n)
}"#,
    );
    assert!(
        !ir.contains("alloca i32"),
        "mut i32 should promote to SSA:\n{ir}"
    );
}

#[test]
fn mutable_string_still_uses_alloca() {
    let ir = compile_ir(
        r#"fn main() {
    let mut s = "hi"
    s = "bye"
    print(s)
}"#,
    );
    assert!(ir.contains("alloca"), "mut string should use stack slot:\n{ir}");
}

#[test]
fn mutable_scalar_loop_uses_phi_for_loop_carried() {
    let ir = compile_ir(
        r#"extern fn blackbox_i32(x: i32) -> i32
fn main() {
    mut acc = 0
    mut i = 0
    while i < 100 {
        acc = (acc + i) % 997
        i = i + 1
    }
    print(blackbox_i32(acc))
}"#,
    );
    let body = main_fn_body(&ir);
    assert!(
        body.contains(" phi i32 "),
        "loop-carried mut scalars should use phi nodes:\n{body}"
    );
    assert!(
        !body.contains("alloca i32"),
        "loop-carried mut i32 should not use alloca:\n{body}"
    );
}

#[test]
fn while_loop_emits_cond_label() {
    let ir = compile_ir(
        r#"fn main() {
    let mut i = 0
    while i < 3 {
        i = i + 1
    }
    print(i)
}"#,
    );
    assert!(ir.contains("while.cond"));
}

#[test]
fn string_literal_uses_global() {
    let ir = compile_ir(
        r#"fn main() {
    let s = "hello"
    print(s)
}"#,
    );
    assert!(ir.contains("@.str") || ir.contains("hello"));
}

#[test]
fn mut_ssa_refmut_spills_to_stack_for_c_out_param() {
    let ir = compile_ir(
        r#"extern fn write_u64(p: ptr) -> void
fn main() {
    let mut n: u64 = 42
    unsafe {
        write_u64((&mut n) as ptr)
    }
    print(n)
}"#,
    );
    assert!(
        ir.contains("alloca") && ir.contains("store i64") || ir.contains("store i32"),
        "mut SSA &mut should spill to stack for a valid C out-param pointer:\n{ir}"
    );
    assert!(
        !ir.contains("bitcast i64* %ssa"),
        "must not treat SSA register as pointer:\n{ir}"
    );
}

#[test]
fn for_range_emits_valid_phi_at_header() {
    let ir = compile_ir(
        r#"fn main() {
    let mut sum = 0
    for i in 1..4 {
        sum = sum + i
    }
    print(sum)
}"#,
    );
    assert!(ir.contains("for.cond"), "expected for.cond label:\n{ir}");
    if let Some(cond) = ir.split("for.cond.").nth(1) {
        let block = cond.split('\n').take(8).collect::<Vec<_>>().join("\n");
        if block.contains("phi") {
            let phi_pos = block.find("phi").unwrap_or(usize::MAX);
            let load_pos = block.find("load").unwrap_or(usize::MAX);
            assert!(
                !block.contains("load") || phi_pos < load_pos,
                "phi must precede load in for.cond header:\n{block}"
            );
        }
    }
}

#[test]
fn array_index_and_mutate_emits_gep_on_stack_slot() {
    let ir = compile_ir(
        r#"fn main() {
    let mut nums = [10, 1, 2]
    nums[1] = 5
    print(nums[1])
}"#,
    );
    assert!(
        ir.contains("getelementptr inbounds [3 x i32]"),
        "expected array gep:\n{ir}"
    );
    assert!(
        !ir.contains("[3 x i32]* %ld"),
        "should not treat loaded aggregate as pointer:\n{ir}"
    );
}

#[test]
fn array_dynamic_index_loads_element() {
    let ir = compile_ir(
        r#"fn main() {
    let mut nums = [10, 1, 2, 8]
    let mut i = 1
    print(nums[i])
}"#,
    );
    assert!(
        ir.contains("getelementptr inbounds [4 x i32]"),
        "expected dynamic index gep:\n{ir}"
    );
}

#[test]
fn array_param_dynamic_index_uses_elem_gep() {
    let ir = compile_ir(
        r#"fn at(data: [i32; 3], i: i32) -> i32 {
    return data[i]
}
fn main() {
    print(at([2, 5, 8], 1))
}"#,
    );
    assert!(
        ir.contains("getelementptr inbounds i32, i32*"),
        "expected element-type gep for dynamic index:\n{ir}"
    );
}

#[test]
fn array_param_spills_to_stack_slot() {
    let ir = compile_ir(
        r#"fn find(data: [i32; 3], want: i32) -> i32 {
    for n in data {
        if n == want {
            return 1
        }
    }
    return 0
}
fn main() {
    print(find([2, 5, 8], 5))
}"#,
    );
    assert!(
        ir.contains("define i32 @find"),
        "expected find function:\n{ir}"
    );
    let find_body = ir.split("define i32 @find").nth(1).unwrap_or("");
    assert!(
        find_body.contains("alloca [3 x i32]"),
        "array param should spill to stack:\n{find_body}"
    );
}

#[test]
fn enum_match_emits_branches() {
    let ir = compile_ir(
        r#"enum Color { Red Green }
fn main() {
    let c = Color.Red
    let n = match c {
        Color.Red => 1
        Color.Green => 2
    }
    print(n)
}"#,
    );
    assert!(ir.contains("switch") || ir.contains("icmp"));
}
