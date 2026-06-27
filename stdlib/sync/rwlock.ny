extern fn rwlock_new() -> ptr
extern fn rwlock_rlock(r: ptr) -> void
extern fn rwlock_wlock(r: ptr) -> void
extern fn rwlock_unlock(r: ptr) -> void
extern fn rwlock_free(r: ptr) -> void

struct RwLock {
    handle: ptr
}

fn RwLock_new() -> RwLock {
    return RwLock { handle: rwlock_new() }
}

impl RwLock {
    fn read(self) -> RwLock {
        rwlock_rlock(self.handle)
        return self
    }

    fn write(self) -> RwLock {
        rwlock_wlock(self.handle)
        return self
    }

    fn unlock(self) -> RwLock {
        rwlock_unlock(self.handle)
        return self
    }
}

impl Drop for RwLock {
    fn drop(self) -> void {
        rwlock_free(self.handle)
    }
}

struct RwLock_i32 {
    inner: RwLock
}

fn RwLock_i32_new() -> RwLock_i32 {
    return RwLock_i32 { inner: RwLock_new() }
}

impl RwLock_i32 {
    fn read(self) -> RwLock_i32 {
        return RwLock_i32 { inner: self.inner.read() }
    }

    fn write(self) -> RwLock_i32 {
        return RwLock_i32 { inner: self.inner.write() }
    }
}
