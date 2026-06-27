import "src/cli.ny"
import "src/unzip.ny"

fn main() {
    return Unzip_run(StrVec_from_argv(1))
}
