fn Cli_usage(tool, text) {
    print(strcat(strcat("usage: ", tool), text))
}

fn DnsLookup_run(args) {
    let n = args.len()
    if n < 1 {
        Cli_usage("DnsLookup", " HOST")
        return 1
    }
    let host = args.get(0)
    print(strcat("lookup: ", host))
    let ips = dns_lookup(host)
    let count = ips.len()
    if count == 0 {
        print("no addresses")
        return 1
    }
    let mut i = 0
    while i < count {
        print(ips.get(i))
        i = i + 1
    }
    return 0
}
