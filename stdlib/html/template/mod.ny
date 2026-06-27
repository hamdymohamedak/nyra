import "../../strings/ops.ny"
import "../../text/template/mod.ny"

fn html_escape(s: string) -> string {
    let mut out = s
    out = str_replace(out, "&", "&amp;")
    out = str_replace(out, "<", "&lt;")
    out = str_replace(out, ">", "&gt;")
    out = str_replace(out, "\"", "&quot;")
    return out
}

fn html_template_execute(tpl: string, key: string, value: string) -> string {
    return template_replace(tpl, key, html_escape(value))
}
