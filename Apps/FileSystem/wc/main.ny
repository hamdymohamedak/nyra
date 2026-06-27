import "src/cli.ny"
import "src/wc.ny"

fn main() {
    return Wc_run(StrVec_from_argv(1))
}
