extern fn mutex_new() -> ptr
extern fn mutex_lock(m: ptr) -> void
extern fn mutex_unlock(m: ptr) -> void
extern fn mutex_free(m: ptr) -> void

struct Mutex {
    handle: ptr
}

fn Mutex_new() -> Mutex {
    return Mutex { handle: mutex_new() }
}

impl Mutex {
    fn lock(self) -> Mutex {
        mutex_lock(self.handle)
        return self
    }

    fn unlock(self) -> Mutex {
        mutex_unlock(self.handle)
        return self
    }
}

impl Drop for Mutex {
    fn drop(self) -> void {
        mutex_free(self.handle)
    }
}

// Legacy alias
struct Mutex_i32 {
    inner: Mutex
}

fn Mutex_i32_new() -> Mutex_i32 {
    return Mutex_i32 { inner: Mutex_new() }
}

impl Mutex_i32 {
    fn lock(self) -> Mutex_i32 {
        return Mutex_i32 { inner: self.inner.lock() }
    }

    fn unlock(self) -> Mutex_i32 {
        return Mutex_i32 { inner: self.inner.unlock() }
    }
}
