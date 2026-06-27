mod spans;
mod unused_imports;
mod unused_vars;
mod prune;

use std::path::Path;

use ast::Program;
use errors::NyraError;

pub use prune::{apply_prune, plan_prune, PruneAction, PrunePlan, PruneResult};
pub use unused_imports::check_unused_imports;
pub use unused_vars::check_unused_variables;

/// Run all compiler lints for a project entry point.
pub fn check_all(entry: &Path, merged: &Program) -> Vec<NyraError> {
    let mut warnings = check_unused_imports(entry, Some(merged));
    warnings.extend(check_unused_variables(merged));
    warnings
}
