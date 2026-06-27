extern fn rt_hw_random_bytes(count: i32) -> string
extern fn rt_hw_secure_enclave_available() -> i32

// OS/hardware TRNG: getentropy, arc4random_buf, BCryptGenRandom, or /dev/urandom.
fn hw_random_bytes(count: i32) -> string {
    return rt_hw_random_bytes(count)
}

fn hw_secure_enclave_available() -> bool {
    return rt_hw_secure_enclave_available() == 1
}

// Note: Intel SGX / full Secure Enclave key APIs require platform FFI beyond this hook.
