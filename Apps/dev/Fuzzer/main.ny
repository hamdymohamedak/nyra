import "src/fuzzer.ny"

fn main() {
    return Fuzzer_run(StrVec_from_argv(1))
}
