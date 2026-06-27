//! Validate explicit `#[derive(Copy)]` / `struct S Copy { }` against field types.

use ast::Program;
use errors::{ErrorKind, NyraError, Span};
use types::Type;

use crate::context::OwnershipCtx;

pub fn check_copy_attrs(program: &Program, ctx: &OwnershipCtx, errors: &mut Vec<NyraError>) {
    for s in &program.structs {
        if !s.attrs.copy {
            continue;
        }
        let ty = Type::Struct(s.name.clone());
        if ctx.kind_of(&ty).is_move() {
            errors.push(
                NyraError::new(
                    ErrorKind::Type,
                    Span::default(),
                    format!("struct '{}' cannot be Copy: not all fields are Copy types", s.name),
                )
                .note("remove #[derive(Copy)] or use Clone/move for heap fields like string"),
            );
        }
    }
}
