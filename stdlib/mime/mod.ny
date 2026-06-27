import "../strings.ny"
import "../strings/ops.ny"
import "../vec_str.ny"

fn mime_parse_media_type(header: string) -> string {
    let semi = strstr_pos(header, ";")
    if semi < 0 {
        return str_trim(header)
    }
    return str_trim(substring(header, 0, semi))
}

fn mime_boundary_from_content_type(ct: string) -> string {
    let key = "boundary="
    let pos = strstr_pos(ct, key)
    if pos < 0 {
        return ""
    }
    let start = pos + strlen(key)
    let rest = substring(ct, start, strlen(ct) - start)
    let semi = strstr_pos(rest, ";")
    if semi >= 0 {
        return str_trim(substring(rest, 0, semi))
    }
    return str_trim(rest)
}

fn mime_multipart_next_part(body: string, boundary: string, start: i32) -> i32 {
    let marker = strcat(strcat("--", boundary), "\r\n")
    return strstr_pos(substring(body, start, strlen(body) - start), marker)
}

fn mime_write_multipart(boundary: string, fields: StrVec) -> string {
    let mut out = ""
    let n = fields.len()
    let mut i = 0
    while i < n {
        let line = fields.get(i)
        let eq = strstr_pos(line, "=")
        if eq >= 0 {
            let name = substring(line, 0, eq)
            let value = substring(line, eq + 1, strlen(line) - eq - 1)
            out = strcat(out, strcat(strcat(strcat(strcat("--", boundary), "\r\nContent-Disposition: form-data; name=\""), name), strcat(strcat("\"\r\n\r\n", value), "\r\n")))
        }
        i = i + 1
    }
    return strcat(strcat(out, "--"), strcat(boundary, "--\r\n"))
}

fn mime_content_type_multipart(boundary: string) -> string {
    return strcat(strcat("multipart/form-data; boundary=", boundary), "")
}
