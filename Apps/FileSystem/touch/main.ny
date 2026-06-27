import "src/cli.ny"
import "src/touch.ny"

fn main() {
    return Touch_run(StrVec_from_argv(1))
}
