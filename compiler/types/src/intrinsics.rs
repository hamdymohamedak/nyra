//! Compiler math intrinsics — lowered to LLVM intrinsics at call sites.

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum MathIntrinsic {
    AbsI32,
    AbsF64,
    MinI32,
    MaxI32,
    MinF64,
    MaxF64,
    ClampI32,
    SinF64,
    CosF64,
    Atan2F64,
    TanF64,
}

/// Names that the compiler implements as intrinsics (stdlib stubs are not codegen'd).
pub fn is_math_intrinsic_fn(name: &str) -> bool {
    resolve_math_intrinsic(name).is_some()
}

pub fn resolve_math_intrinsic(name: &str) -> Option<MathIntrinsic> {
    match name {
        "abs_i32" => Some(MathIntrinsic::AbsI32),
        "abs_f64" => Some(MathIntrinsic::AbsF64),
        "min_i32" => Some(MathIntrinsic::MinI32),
        "max_i32" => Some(MathIntrinsic::MaxI32),
        "min_f64" => Some(MathIntrinsic::MinF64),
        "max_f64" => Some(MathIntrinsic::MaxF64),
        "clamp_i32" => Some(MathIntrinsic::ClampI32),
        "sin" => Some(MathIntrinsic::SinF64),
        "cos" => Some(MathIntrinsic::CosF64),
        "atan2" => Some(MathIntrinsic::Atan2F64),
        "tan" => Some(MathIntrinsic::TanF64),
        _ => None,
    }
}
