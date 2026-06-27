import "../../strings.ny"
import "../../strings/ops.ny"

fn template_placeholder(key: string) -> string {
    return strcat(strcat("{{", key), "}}")
}

fn template_replace(tpl: string, key: string, value: string) -> string {
    let ph = template_placeholder(key)
    return str_replace(tpl, ph, value)
}

fn template_execute(tpl: string, key: string, value: string) -> string {
    return template_replace(tpl, key, value)
}

fn template_execute2(tpl: string, k1: string, v1: string, k2: string, v2: string) -> string {
    let s = template_replace(tpl, k1, v1)
    return template_replace(s, k2, v2)
}
