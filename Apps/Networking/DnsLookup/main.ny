import "src/dns.ny"

fn main() {
    return DnsLookup_run(StrVec_from_argv(1))
}
