import "src/cli.ny"
import "src/ls.ny"

fn main() {
    return Ls_run(StrVec_from_argv(1))
}
