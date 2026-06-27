import "src/cli.ny"
import "src/cat.ny"

fn main() {
    return Cat_run(StrVec_from_argv(1))
}
