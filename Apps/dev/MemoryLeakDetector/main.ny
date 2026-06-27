import "src/leak.ny"

fn main() {
    return LeakDetector_run(StrVec_from_argv(1))
}
