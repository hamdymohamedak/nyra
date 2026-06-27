//! Constant-divisor remainder planning (strength reduction for `%`).

/// Plan for lowering `x urem d` when `d` is a positive constant and `x` is known non-negative.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum UremPlan {
    /// `x & (d - 1)`
    PowerOfTwo { mask: u32 },
    /// Emit `urem i32 x, d` and let LLVM/clang lower the magic multiply.
    General { divisor: u32 },
}

pub fn plan_u32_urem(divisor: u32) -> Option<UremPlan> {
    if divisor == 0 {
        return None;
    }
    if divisor.is_power_of_two() {
        Some(UremPlan::PowerOfTwo {
            mask: divisor - 1,
        })
    } else {
        Some(UremPlan::General { divisor })
    }
}

pub fn parse_nonneg_i32_literal(s: &str) -> Option<i32> {
    if s.chars().all(|c| c.is_ascii_digit() || c == '-') {
        let n: i32 = s.parse().ok()?;
        (n >= 0).then_some(n)
    } else {
        None
    }
}

pub fn parse_i32_literal(expr: &ast::Expression) -> Option<i32> {
    match expr {
        ast::Expression::Literal(ast::Literal::Int(n)) => i32::try_from(*n).ok(),
        _ => None,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn plan_power_of_two() {
        match plan_u32_urem(8).unwrap() {
            UremPlan::PowerOfTwo { mask } => assert_eq!(mask, 7),
            _ => panic!("expected power-of-two plan"),
        }
    }

    #[test]
    fn plan_general_997() {
        assert!(matches!(
            plan_u32_urem(997).unwrap(),
            UremPlan::General { divisor: 997 }
        ));
    }

    #[test]
    fn parse_nonneg_literal() {
        assert_eq!(parse_nonneg_i32_literal("0"), Some(0));
        assert_eq!(parse_nonneg_i32_literal("42"), Some(42));
        assert_eq!(parse_nonneg_i32_literal("-1"), None);
    }
}
