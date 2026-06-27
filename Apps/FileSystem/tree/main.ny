import "src/cli.ny"
import "src/tree.ny"

fn main() {
    return Tree_run(StrVec_from_argv(1))
}
