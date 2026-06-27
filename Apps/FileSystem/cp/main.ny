import "src/cli.ny"
import "src/cp.ny"

fn main() {
    return Cp_run(StrVec_from_argv(1))
}
