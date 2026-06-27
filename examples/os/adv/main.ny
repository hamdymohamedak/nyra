import "../../../stdlib/os.ny"

fn main() {
    print(platform_name())
    print(cpu_logical_cores())

    let core = affinity_set_thread_cpu(0)
    print(core)
    print(affinity_get_thread_cpu())

    let t0 = clock_monotonic_ns()
    let _elapsed = clock_elapsed_ns(t0)

    print(usb_device_count())
    if usb_device_count() > 0 {
        print(usb_device_vid(0))
        print(usb_device_path(0))
    }

    signal_install(SIGINT)
    if signal_poll(SIGINT) {
        print("SIGINT pending")
    }

    print(hw_secure_enclave_available())
    print(perm_geteuid())

    if is_linux() {
        let mq = mqueue_open("nyra_demo", 8, 256)
        if mq >= 0 {
            mqueue_send(mq, "hello-ipc")
            print(mqueue_recv(mq, 256))
            mqueue_close(mq)
        }
    }
}
