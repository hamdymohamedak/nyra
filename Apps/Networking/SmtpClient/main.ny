import "src/smtp.ny"

fn main() {
    return SmtpClient_run(StrVec_from_argv(1))
}
