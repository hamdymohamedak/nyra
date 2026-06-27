//! Map C/clang types to Nyra FFI types.

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum NyraType {
    Void,
    Int(&'static str),
    F64,
    Bool,
    String,
    Ptr,
    /// `repr(C)` struct defined in the same bindings file.
    Struct(String),
}

impl NyraType {
    pub fn nyra_ann(&self) -> String {
        match self {
            NyraType::Void => "void".into(),
            NyraType::Int(name) => (*name).into(),
            NyraType::F64 => "f64".into(),
            NyraType::Bool => "bool".into(),
            NyraType::String => "string".into(),
            NyraType::Ptr => "ptr".into(),
            NyraType::Struct(name) => name.clone(),
        }
    }

    pub fn is_direct_ffi(&self) -> bool {
        !matches!(self, NyraType::Ptr)
    }
}
