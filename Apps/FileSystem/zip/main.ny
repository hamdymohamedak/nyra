import "src/cli.ny"
import "src/zip.ny"

fn main() {
    return Zip_run(StrVec_from_argv(1))
}
