extern fn rt_dns_lookup(host: string) -> string

fn dns_lookup(host: string) -> StrVec {
    let raw = rt_dns_lookup(host)
    if strlen(raw) == 0 {
        return StrVec_new()
    }
    return StrVec_from_lines(raw)
}
