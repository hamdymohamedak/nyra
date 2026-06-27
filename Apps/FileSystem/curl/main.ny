import "src/cli.ny"
import "src/curl.ny"

fn main() {
    return Curl_run(StrVec_from_argv(1))
}
