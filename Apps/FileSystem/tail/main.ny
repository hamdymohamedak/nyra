import "src/cli.ny"
import "src/tail.ny"

fn main() {
    return Tail_run(StrVec_from_argv(1))
}
