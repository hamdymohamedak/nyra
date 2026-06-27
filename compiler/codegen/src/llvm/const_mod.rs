//! Constant-modulus lowering in LLVM IR.
use ast::*;
use crate::const_mod::{plan_u32_urem, UremPlan};

use super::{Codegen, Env, ExprValue};

impl Codegen {
    pub(super) fn mark_zero_init_ssa_i32(&mut self, name: &str) {
        self.zero_init_ssa_vars.insert(name.to_string());
        self.mark_non_negative_i32(name);
    }

    pub(super) fn expr_is_non_negative_i32(&self, expr: &Expression, env: &Env) -> bool {
        let _ = env;
        match expr {
            Expression::Literal(Literal::Int(n)) => *n >= 0,
            Expression::Literal(Literal::Bool(_))
            | Expression::Literal(Literal::Char(_))
            | Expression::Literal(Literal::String(_))
            | Expression::Literal(Literal::Float(_, _)) => false,
            Expression::Variable { name, .. } => {
                self.non_negative_vars.contains(name) || self.zero_init_ssa_vars.contains(name)
            }
            Expression::Binary(bin) => match bin.op {
                BinaryOp::Mod => {
                    if let Some(d) = crate::const_mod::parse_i32_literal(&bin.right) {
                        if d > 0 {
                            // `urem` by a positive constant yields [0, d-1].
                            return self.expr_is_non_negative_i32(&bin.left, env)
                                || self.expr_is_urem_mod_result_non_negative(&bin.left, env);
                        }
                    }
                    false
                }
                BinaryOp::Add | BinaryOp::Mul => {
                    self.expr_is_non_negative_i32(&bin.left, env)
                        && self.expr_is_non_negative_i32(&bin.right, env)
                }
                BinaryOp::Sub => false,
                _ => false,
            },
            Expression::Unary(u) if u.op == UnaryOp::Neg => false,
            Expression::Grouped(inner) => self.expr_is_non_negative_i32(inner, env),
            Expression::Call(c)
                if matches!(c.callee.as_str(), "abs" | "abs_i32" | "abs_f64")
                    && c.args.len() == 1 =>
            {
                self.expr_is_non_negative_i32(&c.args[0], env)
            }
            _ => false,
        }
    }

    /// True when `left % d` (d > 0) will be lowered with `urem` and produce a non-negative value.
    fn expr_is_urem_mod_result_non_negative(&self, left: &Expression, env: &Env) -> bool {
        match left {
            Expression::Literal(Literal::Int(n)) => *n >= 0,
            Expression::Variable { name, .. } => {
                self.non_negative_vars.contains(name) || self.zero_init_ssa_vars.contains(name)
            }
            Expression::Binary(bin) => match bin.op {
                BinaryOp::Mod => {
                    if let Some(d) = crate::const_mod::parse_i32_literal(&bin.right) {
                        d > 0 && self.expr_is_urem_mod_result_non_negative(&bin.left, env)
                    } else {
                        false
                    }
                }
                BinaryOp::Add | BinaryOp::Mul => {
                    self.expr_is_urem_mod_result_non_negative(&bin.left, env)
                        && self.expr_is_urem_mod_result_non_negative(&bin.right, env)
                }
                BinaryOp::Sub => false,
                _ => false,
            },
            Expression::Grouped(inner) => self.expr_is_urem_mod_result_non_negative(inner, env),
            _ => false,
        }
    }

    pub(super) fn mark_non_negative_i32(&mut self, name: &str) {
        self.non_negative_vars.insert(name.to_string());
    }

    pub(super) fn mark_non_negative_from_mod_assign(
        &mut self,
        name: &str,
        value: &Expression,
        env: &Env,
    ) {
        let value = match value {
            Expression::Grouped(inner) => inner.as_ref(),
            other => other,
        };
        if let Expression::Binary(bin) = value {
            if bin.op == BinaryOp::Mod {
                if let Some(d) = crate::const_mod::parse_i32_literal(&bin.right) {
                    if d > 0 && self.expr_is_non_negative_i32(&bin.left, env) {
                        self.mark_non_negative_i32(name);
                    }
                }
            }
        }
    }

    pub(super) fn emit_i32_mod_by_positive_const(
        &mut self,
        left: &ExprValue,
        divisor: i32,
        left_expr: &Expression,
        env: &Env,
    ) -> ExprValue {
        let reg = self.fresh("mod");
        let d = divisor as u32;
        let non_negative = self.expr_is_non_negative_i32(left_expr, env);

        if non_negative {
            if let Some(plan) = plan_u32_urem(d) {
                match plan {
                    UremPlan::PowerOfTwo { mask } => {
                        self.emit(&format!("  %{reg} = and i32 {}, {mask}", left.reg));
                    }
                    UremPlan::General { divisor } => {
                        self.emit(&format!(
                            "  %{reg} = urem i32 {}, {divisor}",
                            left.reg
                        ));
                    }
                }
                return ExprValue {
                    reg: format!("%{reg}"),
                    ty: "i32".into(),
                };
            }
        }

        self.emit(&format!(
            "  %{reg} = srem i32 {}, {divisor}",
            left.reg
        ));
        ExprValue {
            reg: format!("%{reg}"),
            ty: "i32".into(),
        }
    }
}
