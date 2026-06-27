import "src/linter.ny"

fn main() {
    return Lint_run(StrVec_from_argv(1))
}
