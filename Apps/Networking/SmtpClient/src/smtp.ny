fn Cli_usage(tool, text) {
    print(strcat(strcat("usage: ", tool), text))
}

fn SmtpClient_run(args) {
    let n = args.len()
    if n < 4 {
        Cli_usage("SmtpClient", " HOST FROM TO BODY [PORT]")
        return 1
    }
    let host = args.get(0)
    let from = args.get(1)
    let to = args.get(2)
    let body = args.get(3)
    let port = if n >= 5 { str_to_i32(args.get(4)) } else { 587 }
    print(strcat("sending via ", strcat(host, strcat(":", i32_to_string(port)))))
    let mut rc = -1
    if port == 465 {
        rc = Smtp_send_tls(host, 465, from, to, body)
    } else {
        if port == 587 {
            rc = Smtp_send_starttls(host, 587, from, to, body)
        } else {
            rc = Smtp_send(host, port, from, to, body)
        }
    }
    if rc != 0 {
        print("SMTP failed")
        return 1
    }
    print("sent")
    return 0
}
