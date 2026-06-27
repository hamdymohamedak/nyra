use ast::*;
use errors::{ErrorKind, NyraError, Span};
use types::Type;

use crate::TypeChecker;
use crate::TypeEnv;
use crate::VarInfo;

pub fn array_method_borrows_receiver(method: &str) -> bool {
    matches!(method, "length" | "len" | "sort" | "sort_by")
}

impl TypeChecker {
    fn validate_sort_by_cmp(&mut self, cmp_ty: &Type, elem: &Type, sp: &Span) {
        match cmp_ty {
            Type::FnPtr {
                params,
                return_type,
                ..
            } => {
                if params.len() != 2 {
                    self.errors.push(NyraError::new(
                        ErrorKind::Type,
                        sp.clone(),
                        format!(
                            "'.sort_by' comparator expects 2 parameters, got {}",
                            params.len()
                        ),
                    ));
                    return;
                }
                if params[0] != *elem || params[1] != *elem {
                    self.errors.push(NyraError::new(
                        ErrorKind::Type,
                        sp.clone(),
                        format!(
                            "'.sort_by' comparator must be fn({:?}, {:?}) -> i32",
                            elem, elem
                        ),
                    ));
                }
                let ret = return_type
                    .as_ref()
                    .map(|t| t.as_ref())
                    .unwrap_or(&Type::Void);
                if *ret != Type::Integer(ast::IntKind::I32) {
                    self.errors.push(NyraError::new(
                        ErrorKind::Type,
                        sp.clone(),
                        "'.sort_by' comparator must return i32 (<0, 0, or >0)",
                    ));
                }
            }
            _ => {
                self.errors.push(NyraError::new(
                    ErrorKind::Type,
                    sp.clone(),
                    "'.sort_by' expects a comparator fn(element, element) -> i32",
                ));
            }
        }
    }

    fn check_sort_by_arrow(
        &mut self,
        a: &ArrowFnExpr,
        elem: &Type,
        env: &TypeEnv,
        sp: &Span,
    ) -> Type {
        if a.params.len() != 2 {
            self.errors.push(NyraError::new(
                ErrorKind::Type,
                sp.clone(),
                format!("'.sort_by' comparator expects 2 parameters, got {}", a.params.len()),
            ));
        }
        let mut inner = TypeEnv {
            variables: env.variables.clone(),
            functions: env.functions.clone(),
        };
        for p in &a.params {
            if p.destructure.is_empty() {
                inner.variables.insert(
                    p.name.clone(),
                    VarInfo {
                        ty: elem.clone(),
                        mutable: p.mutable,
                    },
                );
            }
        }
        let ret_ty = match &a.body {
            ArrowBody::Expr(e) => self.check_expr(e, &mut inner),
            ArrowBody::Block(b) => {
                self.check_block(b, &mut inner, &Type::Unknown);
                let mut ret = Type::Integer(ast::IntKind::I32);
                for stmt in &b.statements {
                    if let Statement::Return(r) = stmt {
                        ret = if let Some(v) = &r.value {
                            self.check_expr(v, &mut inner)
                        } else {
                            Type::Void
                        };
                    }
                }
                ret
            }
        };
        if ret_ty != Type::Integer(ast::IntKind::I32) && ret_ty != Type::Unknown {
            self.errors.push(NyraError::new(
                ErrorKind::Type,
                sp.clone(),
                "'.sort_by' comparator must return i32 (<0, 0, or >0)",
            ));
        }
        Type::FnPtr {
            lifetime_params: vec![],
            params: vec![elem.clone(), elem.clone()],
            return_type: Some(Box::new(Type::Integer(ast::IntKind::I32))),
        }
    }

    pub(super) fn check_array_method(
        &mut self,
        mc: &MethodCallExpr,
        obj_ty: &Type,
        env: &mut TypeEnv,
        sp: &Span,
    ) -> Option<Type> {
        let Type::Array { elem, len } = obj_ty else {
            return None;
        };
        let Some(n) = *len else {
            if mc.method == "length" || mc.method == "len" || mc.method == "sort" || mc.method == "sort_by"
            {
                self.errors.push(NyraError::new(
                    ErrorKind::Type,
                    sp.clone(),
                    format!("'.{}' requires a fixed-size array", mc.method),
                ));
            }
            return None;
        };

        match mc.method.as_str() {
            "length" | "len" => {
                if !mc.args.is_empty() {
                    self.errors.push(NyraError::new(
                        ErrorKind::Type,
                        sp.clone(),
                        format!("'.{}' expects no arguments", mc.method),
                    ));
                }
                Some(Type::Integer(ast::IntKind::I32))
            }
            "sort" => {
                if !mc.args.is_empty() {
                    self.errors.push(NyraError::new(
                        ErrorKind::Type,
                        sp.clone(),
                        "'.sort' expects no arguments",
                    ));
                }
                if !matches!(elem.as_ref(), Type::Integer(ast::IntKind::I32) | Type::F32 | Type::F64) {
                    self.errors.push(NyraError::new(
                        ErrorKind::Type,
                        sp.clone(),
                        format!(
                            "'.sort' on arrays supports i32 and f64 elements, got {:?}",
                            elem
                        ),
                    ));
                    return Some(Type::Unknown);
                }
                Some(Type::Array {
                    elem: elem.clone(),
                    len: Some(n),
                })
            }
            "sort_by" => {
                if mc.args.len() != 1 {
                    self.errors.push(NyraError::new(
                        ErrorKind::Type,
                        sp.clone(),
                        format!("'.sort_by' expects 1 argument, got {}", mc.args.len()),
                    ));
                } else if let Expression::ArrowFn(a) = &mc.args[0] {
                    self.check_sort_by_arrow(a, elem, env, sp);
                } else {
                    let cmp_ty = self.check_expr(&mc.args[0], env);
                    self.validate_sort_by_cmp(&cmp_ty, elem, sp);
                }
                Some(Type::Array {
                    elem: elem.clone(),
                    len: Some(n),
                })
            }
            _ => None,
        }
    }
}
