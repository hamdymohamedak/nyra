import "../strings.ny"
import "smtp.ny"

fn Mail_message(from: string, to: string, subject: string, body: string) -> string {
    let mut msg = strcat(strcat("From: ", from), "\r\n")
    msg = strcat(strcat(msg, strcat("To: ", to)), "\r\n")
    msg = strcat(strcat(msg, strcat("Subject: ", subject)), "\r\n")
    msg = strcat(strcat(msg, "\r\n"), body)
    return msg
}

fn Mail_send(host: string, port: i32, from: string, to: string, subject: string, body: string) -> i32 {
    let msg = Mail_message(from, to, subject, body)
    return Smtp_send(host, port, from, to, msg)
}
