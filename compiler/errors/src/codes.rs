//! Stable diagnostic codes for `nyra explain E00x` / `P00x`.

pub const E001_IMPORT_NOT_FOUND: &str = "E001";
pub const E002_UNDEFINED_NAME: &str = "E002";
pub const E003_TYPE_MISMATCH: &str = "E003";
pub const E004_CANNOT_INFER: &str = "E004";
pub const E005_UNKNOWN_STRUCT: &str = "E005";
pub const E006_IMMUTABLE_ASSIGN: &str = "E006";
pub const E007_WRONG_ARITY: &str = "E007";
pub const E008_WRONG_ARG_TYPE: &str = "E008";
pub const E009_INVALID_ASSIGN_TARGET: &str = "E009";
pub const E010_BORROW_WHILE_ASSIGNED: &str = "E010";
pub const E011_USE_WHILE_BORROWED: &str = "E011";
pub const E012_USE_AFTER_MOVE: &str = "E012";

pub const W001_EXTENDED_TIER: &str = "W001";
pub const W002_UNUSED_IMPORT: &str = "W002";
pub const W003_UNUSED_VARIABLE: &str = "W003";

/// Parser: anonymous `{ key: value }` object literal.
pub const P001_ANON_OBJECT_LITERAL: &str = "P001";
/// Parser: standalone `{ }` used as expression.
pub const P002_STANDALONE_BLOCK_EXPR: &str = "P002";
/// Parser: missing or invalid parameter name in fn header.
pub const P003_EXPECTED_PARAM_NAME: &str = "P003";
/// Parser: missing `)` after parameter list.
pub const P004_EXPECTED_CLOSE_PAREN_PARAMS: &str = "P004";
/// Parser: missing `(` after function name.
pub const P005_EXPECTED_OPEN_PAREN_FN: &str = "P005";
/// Parser: invalid / unexpected expression (often cascade).
pub const P006_INVALID_EXPRESSION: &str = "P006";
/// Parser: `{` where an expression was expected (often cascade).
pub const P007_UNEXPECTED_LBRACE_EXPR: &str = "P007";
/// Parser: missing `}` to close block.
pub const P008_EXPECTED_CLOSE_BRACE: &str = "P008";
/// Parser: missing `{` to start block.
pub const P009_EXPECTED_OPEN_BRACE: &str = "P009";
/// Parser: item out of place at top level (often cascade).
pub const P010_EXPECTED_TOP_LEVEL_ITEM: &str = "P010";
/// Parser: missing `)` after call / argument list.
pub const P011_EXPECTED_CLOSE_PAREN_ARGS: &str = "P011";
/// Parser: missing `=>` after arrow function parameters.
pub const P012_EXPECTED_ARROW_FAT_ARROW: &str = "P012";
/// Parser: missing `)` (generic).
pub const P013_EXPECTED_CLOSE_PAREN: &str = "P013";
/// Parser: missing `]` after array / index.
pub const P014_EXPECTED_CLOSE_BRACKET: &str = "P014";
/// Parser: other / unclassified syntax error.
pub const P099_UNEXPECTED: &str = "P099";

/// Lexer: invalid character or token.
pub const L001_INVALID_TOKEN: &str = "L001";
