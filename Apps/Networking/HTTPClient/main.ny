import "src/client.ny"

fn main() {
    return HTTPClient_run(StrVec_from_argv(1))
}
