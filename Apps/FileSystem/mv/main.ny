import "src/cli.ny"
import "src/mv.ny"

fn main() {
    return Mv_run(StrVec_from_argv(1))
}
