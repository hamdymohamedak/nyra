import "src/cli.ny"
import "src/rm.ny"

fn main() {
    return Rm_run(StrVec_from_argv(1))
}
