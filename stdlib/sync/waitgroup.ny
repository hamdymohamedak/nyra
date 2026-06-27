extern fn waitgroup_new() -> ptr
extern fn waitgroup_add(wg: ptr, delta: i32) -> void
extern fn waitgroup_done(wg: ptr) -> void
extern fn waitgroup_wait(wg: ptr) -> void
extern fn waitgroup_free(wg: ptr) -> void

struct WaitGroup {
    handle: ptr
}

fn WaitGroup_new() -> WaitGroup {
    let wg = WaitGroup { handle: waitgroup_new() }
    waitgroup_add(wg.handle, 0)
    return wg
}

impl WaitGroup {
    fn add(self, delta: i32) -> WaitGroup {
        waitgroup_add(self.handle, delta)
        return self
    }

    fn done(self) -> WaitGroup {
        waitgroup_done(self.handle)
        return self
    }

    fn wait(self) -> WaitGroup {
        waitgroup_wait(self.handle)
        return self
    }
}

impl Drop for WaitGroup {
    fn drop(self) -> void {
        waitgroup_free(self.handle)
    }
}
