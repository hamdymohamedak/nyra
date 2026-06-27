// Hardware-level network interfaces (MAC, link state). For TCP/HTTP use stdlib/net/.
extern fn hw_net_if_count() -> i32
extern fn hw_net_if_name(index: i32) -> string
extern fn hw_net_if_mac(index: i32) -> string
extern fn hw_net_if_is_up(index: i32) -> i32

fn net_interface_count() -> i32 {
    return hw_net_if_count()
}

fn net_interface_name(index: i32) -> string {
    return hw_net_if_name(index)
}

fn net_interface_mac(index: i32) -> string {
    return hw_net_if_mac(index)
}

fn net_interface_is_up(index: i32) -> bool {
    return hw_net_if_is_up(index) == 1
}
