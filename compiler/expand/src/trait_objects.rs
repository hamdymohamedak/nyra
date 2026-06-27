//! Synthesize `Dyn_Trait` fat-pointer structs for trait object types.

use ast::*;

pub fn synthesize_trait_object_structs(program: &mut Program) {
    for trait_def in &program.traits {
        if trait_def.name == "Drop" || trait_def.name == "Clone" {
            continue;
        }
        let dyn_name = format!("Dyn_{}", trait_def.name);
        if program.structs.iter().any(|s| s.name == dyn_name) {
            continue;
        }
        program.structs.push(StructDef {
            name: dyn_name,
            doc: None,
            type_params: vec![],
            attrs: StructAttrs::default(),
            fields: vec![
                StructField {
                    name: "data".into(),
                    ty: TypeAnnotation::Ptr,
                },
                StructField {
                    name: "vtable".into(),
                    ty: TypeAnnotation::Ptr,
                },
            ],
            public: true,
        });
    }
}
