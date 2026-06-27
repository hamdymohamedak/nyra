fn Cli_usage(tool, text) {
    print(strcat(strcat("usage: ", tool), text))
}

fn FtpClient_run(args) {
    let n = args.len()
    if n < 3 {
        Cli_usage("FtpClient", " HOST USER PASS [REMOTE_FILE]")
        return 1
    }
    let host = args.get(0)
    let user = args.get(1)
    let pass = args.get(2)
    let remote = if n >= 4 { args.get(3) } else { "" }
    let stream = Ftp_login(host, user, pass)
    if stream.fd < 0 {
        print("login failed")
        return 1
    }
    print(Ftp_pwd(stream))
    if strlen(remote) > 0 {
        let data = Ftp_retr(stream, host, remote)
        if strlen(data) > 0 {
            print(data)
        }
    } else {
        let listing = Ftp_list(stream, host)
        if strlen(listing) > 0 {
            print(listing)
        }
    }
    Ftp_quit(stream)
    return 0
}
