//! Synthesize `Future_*` handle structs for async v2 desugar.

use ast::*;

fn future_struct_def(name: &str) -> StructDef {
    StructDef {
        name: name.into(),
        type_params: vec![],
        fields: vec![StructField {
            name: "handle".into(),
            ty: TypeAnnotation::Integer(ast::IntKind::I32),
        }],
        attrs: StructAttrs::default(),
        doc: None,
        public: true,
    }
}

pub fn synthesize_future_structs(program: &mut Program) {
    let needs_future = program.functions.iter().any(|f| f.is_async)
        || program.impls.iter().flat_map(|i| &i.methods).any(|m| m.is_async)
        || program.trait_impls.iter().flat_map(|t| &t.methods).any(|m| m.is_async);
    if !needs_future {
        return;
    }
    for name in ["Future_i32", "Future_bool", "Future_string"] {
        if program.structs.iter().any(|s| s.name == name) {
            continue;
        }
        program.structs.push(future_struct_def(name));
    }
}
