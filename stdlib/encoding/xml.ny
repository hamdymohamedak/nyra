import "../strings.ny"
import "../strings/ops.ny"
import "../vec_str.ny"

fn xml_escape(s: string) -> string {
    let mut out = s
    out = str_replace(out, "&", "&amp;")
    out = str_replace(out, "<", "&lt;")
    out = str_replace(out, ">", "&gt;")
    out = str_replace(out, "\"", "&quot;")
    return out
}

fn xml_element(tag: string, text: string) -> string {
    return strcat(
        strcat(strcat(strcat("<", tag), ">"), xml_escape(text)),
        strcat(strcat("</", tag), ">")
    )
}

fn xml_attr_element(tag: string, attr: string, value: string, text: string) -> string {
    return strcat(
        strcat(
            strcat(strcat(strcat(strcat("<", tag), " "), attr), strcat("=\"", strcat(value, "\""))),
            strcat(strcat(">", xml_escape(text)), strcat(strcat("</", tag), ">"))
        ),
        ""
    )
}

fn xml_decode_tag_text(xml: string, tag: string) -> string {
    let open = strcat(strcat("<", tag), ">")
    let close = strcat(strcat("</", tag), ">")
    let start = strstr_pos(xml, open)
    if start < 0 {
        return ""
    }
    let content_start = start + strlen(open)
    let rest = substring(xml, content_start, strlen(xml) - content_start)
    let end = strstr_pos(rest, close)
    if end < 0 {
        return ""
    }
    return substring(rest, 0, end)
}
