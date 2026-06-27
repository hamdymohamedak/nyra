import "src/lexer.ny"

fn main(){
    return Lexer_run(StrVec_from_argv(1))
}
