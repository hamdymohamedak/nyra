//! Extended-tier stability warnings (Nyra v1.2+ — all preview features promoted).

use ast::Program;
use errors::NyraError;

use crate::FeatureSet;

/// Scan a program for Extended-tier features and emit stability warnings.
///
/// As of **v1.2**, async/await, traits, macros, lifetimes, defer, struct spread,
/// and stdlib serde are **Stable Extended** — this returns no W001 warnings.
/// `--deny-extended` remains for future preview features.
pub fn extended_tier_warnings(
    _program: &Program,
    _features: &FeatureSet,
    _entry_file: Option<&str>,
) -> Vec<NyraError> {
    Vec::new()
}
