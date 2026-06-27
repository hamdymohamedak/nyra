import "../net/tcp.ny"
import "../tls.ny"
import "../strings.ny"

fn smtp_send_line(stream: TcpStream, line: string) -> void {
    let msg = strcat(strcat(line, "\r\n"), "")
    tcp_write(stream, msg)
}

fn smtp_expect_ok(stream: TcpStream) -> i32 {
    let resp = tcp_read(stream, 512)
    if strlen(resp) < 3 {
        return -1
    }
    if char_at(resp, 0) == 50 || char_at(resp, 0) == 51 {
        return 0
    }
    return -1
}

fn Smtp_send(host: string, port: i32, from: string, to: string, body: string) -> i32 {
    let stream = tcp_connect(host, port)
    if stream.fd < 0 {
        return -1
    }
    if smtp_expect_ok(stream) != 0 {
        tcp_close_stream(stream)
        return -1
    }
    smtp_send_line(stream, strcat("EHLO ", host))
    if smtp_expect_ok(stream) != 0 {
        tcp_close_stream(stream)
        return -1
    }
    smtp_send_line(stream, strcat("MAIL FROM:<", strcat(from, ">")))
    if smtp_expect_ok(stream) != 0 {
        tcp_close_stream(stream)
        return -1
    }
    smtp_send_line(stream, strcat("RCPT TO:<", strcat(to, ">")))
    if smtp_expect_ok(stream) != 0 {
        tcp_close_stream(stream)
        return -1
    }
    smtp_send_line(stream, "DATA")
    if smtp_expect_ok(stream) != 0 {
        tcp_close_stream(stream)
        return -1
    }
    smtp_send_line(stream, body)
    smtp_send_line(stream, ".")
    if smtp_expect_ok(stream) != 0 {
        tcp_close_stream(stream)
        return -1
    }
    smtp_send_line(stream, "QUIT")
    tcp_close_stream(stream)
    return 0
}

fn smtp_stream_tls(host: string, port: i32) -> i32 {
    if tls_available() == 0 {
        return -1
    }
    return tls_connect_verify(host, port)
}

fn smtp_expect_ok_tls(fd: i32) -> i32 {
    let resp = tls_read(fd, 512)
    if strlen(resp) < 3 {
        return -1
    }
    if char_at(resp, 0) == 50 || char_at(resp, 0) == 51 {
        return 0
    }
    return -1
}

fn smtp_send_line_tls(fd: i32, line: string) -> void {
    let msg = strcat(strcat(line, "\r\n"), "")
    tls_write(fd, msg)
}

fn Smtp_send_tls(host: string, port: i32, from: string, to: string, body: string) -> i32 {
    let fd = smtp_stream_tls(host, port)
    if fd < 0 {
        return -1
    }
    if smtp_expect_ok_tls(fd) != 0 {
        tls_close(fd)
        return -1
    }
    smtp_send_line_tls(fd, strcat("EHLO ", host))
    if smtp_expect_ok_tls(fd) != 0 {
        tls_close(fd)
        return -1
    }
    smtp_send_line_tls(fd, strcat("MAIL FROM:<", strcat(from, ">")))
    if smtp_expect_ok_tls(fd) != 0 {
        tls_close(fd)
        return -1
    }
    smtp_send_line_tls(fd, strcat("RCPT TO:<", strcat(to, ">")))
    if smtp_expect_ok_tls(fd) != 0 {
        tls_close(fd)
        return -1
    }
    smtp_send_line_tls(fd, "DATA")
    if smtp_expect_ok_tls(fd) != 0 {
        tls_close(fd)
        return -1
    }
    smtp_send_line_tls(fd, body)
    smtp_send_line_tls(fd, ".")
    if smtp_expect_ok_tls(fd) != 0 {
        tls_close(fd)
        return -1
    }
    smtp_send_line_tls(fd, "QUIT")
    tls_close(fd)
    return 0
}

fn smtp_starttls(stream: TcpStream, host: string) -> i32 {
    smtp_send_line(stream, "STARTTLS")
    if smtp_expect_ok(stream) != 0 {
        return -1
    }
    if tls_available() == 0 {
        return -1
    }
    return tls_upgrade_verify(stream.fd, host)
}

fn Smtp_send_starttls(host: string, port: i32, from: string, to: string, body: string) -> i32 {
    let stream = tcp_connect(host, port)
    if stream.fd < 0 {
        return -1
    }
    if smtp_expect_ok(stream) != 0 {
        tcp_close_stream(stream)
        return -1
    }
    smtp_send_line(stream, strcat("EHLO ", host))
    if smtp_expect_ok(stream) != 0 {
        tcp_close_stream(stream)
        return -1
    }
    let tls_fd = smtp_starttls(stream, host)
    if tls_fd < 0 {
        tcp_close_stream(stream)
        return -1
    }
    smtp_send_line_tls(tls_fd, strcat("EHLO ", host))
    if smtp_expect_ok_tls(tls_fd) != 0 {
        tls_close(tls_fd)
        return -1
    }
    smtp_send_line_tls(tls_fd, strcat("MAIL FROM:<", strcat(from, ">")))
    if smtp_expect_ok_tls(tls_fd) != 0 {
        tls_close(tls_fd)
        return -1
    }
    smtp_send_line_tls(tls_fd, strcat("RCPT TO:<", strcat(to, ">")))
    if smtp_expect_ok_tls(tls_fd) != 0 {
        tls_close(tls_fd)
        return -1
    }
    smtp_send_line_tls(tls_fd, "DATA")
    if smtp_expect_ok_tls(tls_fd) != 0 {
        tls_close(tls_fd)
        return -1
    }
    smtp_send_line_tls(tls_fd, body)
    smtp_send_line_tls(tls_fd, ".")
    if smtp_expect_ok_tls(tls_fd) != 0 {
        tls_close(tls_fd)
        return -1
    }
    smtp_send_line_tls(tls_fd, "QUIT")
    tls_close(tls_fd)
    return 0
}
