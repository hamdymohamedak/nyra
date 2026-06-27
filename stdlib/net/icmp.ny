import "tcp.ny"

extern fn rt_tcp_ping_ms(host: string, port: i32, timeout_ms: i32) -> i32
extern fn rt_icmp_ping_ms(host: string, timeout_ms: i32) -> i32
extern fn rt_icmp_ping_system_ms(host: string, timeout_ms: i32) -> i32
extern fn rt_icmp_capable() -> i32

const PING_ICMP_NEED_ROOT = -2

fn ping_tcp(host: string, port: i32, timeout_ms: i32) -> i32 {
    return rt_tcp_ping_ms(host, port, timeout_ms)
}

fn ping_icmp(host: string, timeout_ms: i32) -> i32 {
    return rt_icmp_ping_ms(host, timeout_ms)
}

fn ping_icmp_system(host: string, timeout_ms: i32) -> i32 {
    return rt_icmp_ping_system_ms(host, timeout_ms)
}

fn ping_icmp_capable() -> i32 {
    return rt_icmp_capable()
}

fn ping_icmp_hint(ms: i32) -> string {
    if ms == PING_ICMP_NEED_ROOT {
        let cap = ping_icmp_capable()
        if cap == 1 {
            return "ICMP socket unavailable"
        }
        if cap == 0 {
            return "ICMP requires elevated privileges on this OS"
        }
        return "ICMP not supported on this platform"
    }
    if ms < 0 {
        return "host unreachable"
    }
    return ""
}

fn ping_auto(host: string, port: i32, timeout_ms: i32) -> i32 {
    let icmp = ping_icmp(host, timeout_ms)
    if icmp >= 0 {
        return icmp
    }
    if icmp == PING_ICMP_NEED_ROOT {
        let sys = ping_icmp_system(host, timeout_ms)
        if sys >= 0 {
            return sys
        }
    }
    return ping_tcp(host, port, timeout_ms)
}

fn ping_auto_verbose(host: string, port: i32, timeout_ms: i32) -> i32 {
    let icmp = ping_icmp(host, timeout_ms)
    if icmp >= 0 {
        return icmp
    }
    if icmp == PING_ICMP_NEED_ROOT {
        let hint = ping_icmp_hint(icmp)
        if strlen(hint) > 0 {
            print(strcat(strcat(hint, " — trying system ping to "), host))
        }
        let sys = ping_icmp_system(host, timeout_ms)
        if sys >= 0 {
            return sys
        }
        let port_str = i32_to_string(port)
        let target = strcat(strcat(host, ":"), port_str)
        print(strcat("system ping failed — using TCP to ", target))
        return ping_tcp(host, port, timeout_ms)
    }
    let hint = ping_icmp_hint(icmp)
    let port_str = i32_to_string(port)
    let target = strcat(strcat(host, ":"), port_str)
    if strlen(hint) > 0 {
        print(strcat(strcat(hint, " — using TCP to "), target))
    }
    return ping_tcp(host, port, timeout_ms)
}

fn ping(host: string) -> i32 {
    return ping_auto(host, 80, 3000)
}

fn ping_port(host: string, port: i32) -> i32 {
    return ping_auto(host, port, 3000)
}
