import "src/sha256.ny"

fn main(){
    return SHA256_run(StrVec_from_argv(1))
}
