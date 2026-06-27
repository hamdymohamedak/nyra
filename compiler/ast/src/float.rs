//! IEEE-754 floating-point kinds (`f32`, `f64`).

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum FloatKind {
    F32,
    F64,
}

impl FloatKind {
    pub const ALL: [FloatKind; 2] = [FloatKind::F32, FloatKind::F64];

    pub fn parse_name(name: &str) -> Option<FloatKind> {
        match name {
            "f32" => Some(FloatKind::F32),
            "f64" => Some(FloatKind::F64),
            _ => None,
        }
    }

    pub fn name(self) -> &'static str {
        match self {
            FloatKind::F32 => "f32",
            FloatKind::F64 => "f64",
        }
    }

    pub fn llvm_name(self) -> &'static str {
        match self {
            FloatKind::F32 => "float",
            FloatKind::F64 => "double",
        }
    }

    /// Default inferred type for float literals without suffix.
    pub fn default_literal() -> FloatKind {
        FloatKind::F64
    }

    pub fn unify(a: FloatKind, b: FloatKind) -> FloatKind {
        if a == FloatKind::F64 || b == FloatKind::F64 {
            FloatKind::F64
        } else {
            FloatKind::F32
        }
    }
}
