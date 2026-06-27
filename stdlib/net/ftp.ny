import "tcp.ny"
import "../strings.ny"

fn Ftp_read_line(stream: TcpStream) -> string {
    return tcp_read(stream, 512)
}

fn Ftp_expect_code(line: string, code: i32) -> i32 {
    if strlen(line) < 3 {
        return 0
    }
    let c0 = char_at(line, 0)
    let c1 = char_at(line, 1)
    let c2 = char_at(line, 2)
    let d0 = code / 100
    let d1 = (code / 10) % 10
    let d2 = code % 10
    if c0 == 48 + d0 && c1 == 48 + d1 && c2 == 48 + d2 {
        return 1
    }
    return 0
}

fn Ftp_cmd(stream: TcpStream, line: string) -> string {
    tcp_write(stream, strcat(line, "\r\n"))
    return Ftp_read_line(stream)
}

fn Ftp_parse_pasv_port(line: string) -> i32 {
    let open = strstr_pos(line, "(")
    if open < 0 {
        return -1
    }
    let inside = substring(line, open + 1, strlen(line) - (open + 1))
    let close = strstr_pos(inside, ")")
    if close < 0 {
        return -1
    }
    let body = substring(inside, 0, close)
    let mut nums = [0; 6]
    let mut count = 0
    let mut i = 0
    let mut cur = 0
    let mut has = 0
    let n = strlen(body)
    while i < n && count < 6 {
        let c = char_at(body, i)
        if c >= 48 && c <= 57 {
            cur = cur * 10 + (c - 48)
            has = 1
        } else {
            if c == 44 && has == 1 {
                nums[count] = cur
                count = count + 1
                cur = 0
                has = 0
            }
        }
        i = i + 1
    }
    if has == 1 && count < 6 {
        nums[count] = cur
        count = count + 1
    }
    if count < 6 {
        return -1
    }
    return nums[4] * 256 + nums[5]
}

fn Ftp_data_read(control: TcpStream, host: string, data_port: i32) -> string {
    let data = tcp_connect(host, data_port)
    if data.fd < 0 {
        return ""
    }
    Ftp_read_line(control)
    let body = tcp_read(data, 65536)
    tcp_close_stream(data)
    let done = Ftp_read_line(control)
    if Ftp_expect_code(done, 226) == 0 {
        return body
    }
    return body
}

fn Ftp_login(host: string, user: string, pass: string) -> TcpStream {
    let stream = tcp_connect(host, 21)
    if stream.fd < 0 {
        return stream
    }
    let welcome = Ftp_read_line(stream)
    if Ftp_expect_code(welcome, 220) == 0 {
        tcp_close_stream(stream)
        return TcpStream { fd: -1 }
    }
    let user_resp = Ftp_cmd(stream, strcat("USER ", user))
    if Ftp_expect_code(user_resp, 331) == 0 && Ftp_expect_code(user_resp, 230) == 0 {
        tcp_close_stream(stream)
        return TcpStream { fd: -1 }
    }
    let pass_resp = Ftp_cmd(stream, strcat("PASS ", pass))
    if Ftp_expect_code(pass_resp, 230) == 0 {
        tcp_close_stream(stream)
        return TcpStream { fd: -1 }
    }
    return stream
}

fn Ftp_list(control: TcpStream, host: string) -> string {
    let pasv = Ftp_cmd(control, "PASV")
    if Ftp_expect_code(pasv, 227) == 0 {
        return ""
    }
    let data_port = Ftp_parse_pasv_port(pasv)
    if data_port < 0 {
        return ""
    }
    Ftp_cmd(control, "LIST")
    return Ftp_data_read(control, host, data_port)
}

fn Ftp_retr(control: TcpStream, host: string, remote_path: string) -> string {
    let pasv = Ftp_cmd(control, "PASV")
    if Ftp_expect_code(pasv, 227) == 0 {
        return ""
    }
    let data_port = Ftp_parse_pasv_port(pasv)
    if data_port < 0 {
        return ""
    }
    Ftp_cmd(control, strcat("RETR ", remote_path))
    return Ftp_data_read(control, host, data_port)
}

fn Ftp_stor(control: TcpStream, host: string, remote_path: string, content: string) -> i32 {
    let pasv = Ftp_cmd(control, "PASV")
    if Ftp_expect_code(pasv, 227) == 0 {
        return -1
    }
    let data_port = Ftp_parse_pasv_port(pasv)
    if data_port < 0 {
        return -1
    }
    Ftp_cmd(control, strcat("STOR ", remote_path))
    let data = tcp_connect(host, data_port)
    if data.fd < 0 {
        return -1
    }
    Ftp_read_line(control)
    tcp_write(data, content)
    tcp_close_stream(data)
    let done = Ftp_read_line(control)
    if Ftp_expect_code(done, 226) == 0 {
        return -1
    }
    return 0
}

fn Ftp_pwd(control: TcpStream) -> string {
    return Ftp_cmd(control, "PWD")
}

fn Ftp_quit(control: TcpStream) -> void {
    Ftp_cmd(control, "QUIT")
    tcp_close_stream(control)
}
