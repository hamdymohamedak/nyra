//! Fixed-width signed/unsigned integers (`i8`…`i128`, `u8`…`u128`, `isize`, `usize`).

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum IntKind {
    I8,
    I16,
    I32,
    I64,
    I128,
    U8,
    U16,
    U32,
    U64,
    U128,
    ISize,
    USize,
}

impl IntKind {
    pub const ALL: [IntKind; 12] = [
        IntKind::I8,
        IntKind::I16,
        IntKind::I32,
        IntKind::I64,
        IntKind::I128,
        IntKind::U8,
        IntKind::U16,
        IntKind::U32,
        IntKind::U64,
        IntKind::U128,
        IntKind::ISize,
        IntKind::USize,
    ];

    pub fn parse_name(name: &str) -> Option<IntKind> {
        match name {
            "i8" => Some(IntKind::I8),
            "i16" => Some(IntKind::I16),
            "i32" => Some(IntKind::I32),
            "i64" => Some(IntKind::I64),
            "i128" => Some(IntKind::I128),
            "u8" => Some(IntKind::U8),
            "u16" => Some(IntKind::U16),
            "u32" => Some(IntKind::U32),
            "u64" => Some(IntKind::U64),
            "u128" => Some(IntKind::U128),
            "isize" => Some(IntKind::ISize),
            "usize" => Some(IntKind::USize),
            _ => None,
        }
    }

    pub fn name(self) -> &'static str {
        match self {
            IntKind::I8 => "i8",
            IntKind::I16 => "i16",
            IntKind::I32 => "i32",
            IntKind::I64 => "i64",
            IntKind::I128 => "i128",
            IntKind::U8 => "u8",
            IntKind::U16 => "u16",
            IntKind::U32 => "u32",
            IntKind::U64 => "u64",
            IntKind::U128 => "u128",
            IntKind::ISize => "isize",
            IntKind::USize => "usize",
        }
    }

    pub fn is_signed(self) -> bool {
        matches!(
            self,
            IntKind::I8
                | IntKind::I16
                | IntKind::I32
                | IntKind::I64
                | IntKind::I128
                | IntKind::ISize
        )
    }

    /// LLVM integer type name (unsigned uses the same bitwidth as signed in LLVM IR).
    pub fn llvm_name(self) -> &'static str {
        match self {
            IntKind::I8 | IntKind::U8 => "i8",
            IntKind::I16 | IntKind::U16 => "i16",
            IntKind::I32 | IntKind::U32 => "i32",
            IntKind::I64 | IntKind::U64 | IntKind::ISize | IntKind::USize => "i64",
            IntKind::I128 | IntKind::U128 => "i128",
        }
    }

    pub fn bits(self) -> u16 {
        match self {
            IntKind::I8 | IntKind::U8 => 8,
            IntKind::I16 | IntKind::U16 => 16,
            IntKind::I32 | IntKind::U32 => 32,
            IntKind::I64 | IntKind::U64 | IntKind::ISize | IntKind::USize => 64,
            IntKind::I128 | IntKind::U128 => 128,
        }
    }

    /// Default inferred type for integer literals.
    pub fn default_literal() -> IntKind {
        IntKind::I32
    }

    /// Whether an `i64` literal fits this fixed-width integer type.
    pub fn literal_fits_i64(self, n: i64) -> bool {
        match self {
            IntKind::I8 => (-128..=127).contains(&n),
            IntKind::I16 => (-32_768..=32_767).contains(&n),
            IntKind::I32 => (-2_147_483_648..=2_147_483_647).contains(&n),
            IntKind::I64 | IntKind::ISize | IntKind::I128 => true,
            IntKind::U8 => (0..=255).contains(&n),
            IntKind::U16 => (0..=65_535).contains(&n),
            IntKind::U32 => (0..=4_294_967_295).contains(&n),
            IntKind::U64 | IntKind::USize | IntKind::U128 => n >= 0,
        }
    }

    /// Widen two integer kinds for mixed arithmetic (Rust-style: pick widest; signed if mixed).
    pub fn unify(a: IntKind, b: IntKind) -> IntKind {
        let bits = a.bits().max(b.bits());
        let signed = a.is_signed() || b.is_signed();
        match bits {
            128 => {
                if signed {
                    IntKind::I128
                } else {
                    IntKind::U128
                }
            }
            64 => {
                if signed {
                    IntKind::I64
                } else {
                    IntKind::U64
                }
            }
            32 => {
                if signed {
                    IntKind::I32
                } else {
                    IntKind::U32
                }
            }
            16 => {
                if signed {
                    IntKind::I16
                } else {
                    IntKind::U16
                }
            }
            _ => {
                if signed {
                    IntKind::I8
                } else {
                    IntKind::U8
                }
            }
        }
    }
}
