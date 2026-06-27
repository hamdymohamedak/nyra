//! Built-in I/O (`print`, buffered writes) argument checking.

use ast::*;
use errors::{ErrorKind, NyraError, Span};

use super::{TypeChecker, TypeEnv};
use super::diagnostics;
use types::{self, Type};

impl TypeChecker {
    pub(super) fn check_io_arg(
        &mut self,
        arg: &Expression,
        env: &mut TypeEnv,
        sp: Span,
        callee: &str,
    ) {
        match arg {
            Expression::TemplateLiteral(t) => {
                for part in &t.parts {
                    if let TemplatePart::Interpolation(expr) = part {
                        let ty = self.check_expr(expr, env);
                        if !types::is_print_arg(&ty) {
                            self.errors.push(NyraError::new(
                                ErrorKind::Type,
                                t.span.clone(),
                                format!(
                                    "Template interpolation must be a printable scalar or fixed array, got {ty:?}"
                                ),
                            ));
                        }
                    }
                }
            }
            other => {
                let ty = self.check_expr(other, env);
                if !types::is_print_arg(&ty) {
                    if callee == "print" {
                        diagnostics::invalid_print_arg(self, &ty, sp);
                    } else {
                        self.errors.push(NyraError::new(
                            ErrorKind::Type,
                            sp,
                            format!(
                                "'{callee}' argument must be a printable scalar or fixed array, got {ty:?}"
                            ),
                        ));
                    }
                }
            }
        }
    }

    pub(super) fn check_print_color(&mut self, color: &Expression, env: &mut TypeEnv, sp: Span) {
        match color {
            Expression::Literal(Literal::String(_)) => {}
            Expression::Variable { name, .. } if !env.variables.contains_key(name) => {}
            other => {
                let ty = self.check_expr(other, env);
                if ty != Type::String && ty != Type::Unknown {
                    self.errors.push(NyraError::new(
                        ErrorKind::Type,
                        sp,
                        format!("print color must be a string or color name, got {ty:?}"),
                    ));
                }
            }
        }
    }
}
