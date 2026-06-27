import "src/ftp.ny"

fn main() {
    return FtpClient_run(StrVec_from_argv(1))
}
