import "src/cli.ny"
import "src/explorer.ny"

fn main() {
    return Explorer_run(StrVec_from_argv(1))
}
