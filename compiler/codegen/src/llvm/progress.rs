#![allow(unused_imports)]
//! `progress for` — automatic progress bar emission each iteration.
use ast::*;

use super::Codegen;

impl Codegen {
    pub(super) fn setup_progress_label(&mut self, f: &ForStmt, env: &super::Env) -> String {
        if let Some(ProgressConfig {
            label: Some(expr),
        }) = &f.progress
        {
            if let Expression::Literal(Literal::String(s)) = expr {
                let text = Self::format_progress_label_text(s);
                let idx = self.intern_string(&text);
                let gep = self.fresh("prog.lbl");
                self.emit(&format!(
                    "  %{gep} = getelementptr inbounds i8, ptr @.str.{idx}, i64 0"
                ));
                return format!("%{gep}");
            }
            let v = self.compile_expr(expr, env);
            let reg = if v.reg.starts_with('%') {
                v.reg.clone()
            } else {
                format!("%{}", v.reg)
            };
            if v.ty == "ptr" {
                return reg;
            }
        }

        let text = Self::default_progress_label(f);
        let idx = self.intern_string(&text);
        let gep = self.fresh("prog.lbl");
        self.emit(&format!(
            "  %{gep} = getelementptr inbounds i8, ptr @.str.{idx}, i64 0"
        ));
        format!("%{gep}")
    }

    fn format_progress_label_text(s: &str) -> String {
        if s.ends_with("...") {
            if s.starts_with("Running") {
                s.to_string()
            } else {
                format!("Running {s}")
            }
        } else if s.starts_with("Running") {
            format!("{s}...")
        } else {
            format!("Running {s}...")
        }
    }

    fn default_progress_label(f: &ForStmt) -> String {
        if let ForKind::Iterable {
            iterable: Expression::Variable { name, .. },
        } = &f.kind
        {
            return format!("Running {name}...");
        }
        "Processing...".to_string()
    }

    pub(super) fn emit_progress_step(
        &mut self,
        current_1based: &str,
        total_op: &str,
        label_ptr: &str,
    ) {
        let cur = Self::progress_i32_operand(current_1based);
        let tot = Self::progress_i32_operand(total_op);
        let lbl = if label_ptr.starts_with('%') || label_ptr.starts_with('@') {
            label_ptr.to_string()
        } else {
            format!("%{label_ptr}")
        };
        self.emit_runtime_call(
            "progress_update",
            &format!("  call void @progress_update(i32 {cur}, i32 {tot}, ptr {lbl})"),
        );
    }

    pub(super) fn emit_progress_finish(&mut self) {
        self.emit_runtime_call("progress_finish", "  call void @progress_finish()");
    }

    /// `idx_0` is the zero-based loop index SSA name (without `%`).
    pub(super) fn emit_progress_from_index(
        &mut self,
        idx_0: &str,
        total_op: &str,
        label_ptr: &str,
        range_start: Option<&str>,
    ) {
        let one = self.fresh("prog.one");
        self.emit(&format!("  %{one} = add i32 0, 1"));
        let base = self.fresh("prog.idx");
        self.emit(&format!("  %{base} = add i32 0, %{idx_0}"));
        let cur1 = if let Some(start) = range_start {
            let start_op = Self::progress_i32_operand(start);
            let rel = self.fresh("prog.rel");
            self.emit(&format!("  %{rel} = sub i32 %{base}, {start_op}"));
            let c = self.fresh("prog.cur");
            self.emit(&format!("  %{c} = add i32 %{rel}, 1"));
            c
        } else {
            let c = self.fresh("prog.cur");
            self.emit(&format!("  %{c} = add i32 %{base}, 1"));
            c
        };
        self.emit_progress_step(&cur1, total_op, label_ptr);
    }

    fn progress_i32_operand(reg: &str) -> String {
        Self::llvm_int_operand(reg)
    }

    pub(super) fn llvm_int_operand(reg: &str) -> String {
        if reg.starts_with('%') || reg.chars().all(|c| c.is_ascii_digit() || c == '-') {
            reg.to_string()
        } else {
            format!("%{reg}")
        }
    }
}
