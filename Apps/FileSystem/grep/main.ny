import "src/cli.ny"
import "src/grep.ny"

fn main() {
    return Grep_run(StrVec_from_argv(1))
}
