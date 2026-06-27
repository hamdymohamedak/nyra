import "src/cli.ny"
import "src/tar.ny"

fn main() {
    return Tar_run(StrVec_from_argv(1))
}
