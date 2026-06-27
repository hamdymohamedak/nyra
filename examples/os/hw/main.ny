import "../../../stdlib/os.ny"

fn main() {
    print(platform_name())
    print(cpu_brand())
    print(cpu_physical_cores())
    print(cpu_logical_cores())
    print(cpu_cache_line_size())
    print(cpu_has_avx2())

    if is_windows() {
        print(disk_fs_type("C:\\"))
    } else {
        print(disk_fs_type("/"))
    }

    let n = net_interface_count()
    print(n)
    if n > 0 {
        print(net_interface_name(0))
        print(net_interface_mac(0))
    }

    print(display_width())
    print(display_height())
    print(power_on_ac())
    print(battery_percent())
}
