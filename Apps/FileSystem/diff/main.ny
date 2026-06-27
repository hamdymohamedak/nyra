import "src/cli.ny"
import "src/diff.ny"

fn main() {
    return Diff_run(StrVec_from_argv(1))
}
