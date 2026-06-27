// Reference-counted shared ownership (v2.5) — generic Arc<T> via monomorph + typed runtime cells.

extern fn arc_alloc_i32(value: i32) -> ptr
extern fn arc_alloc_string(value: string) -> ptr
extern fn arc_inc(handle: ptr) -> void
extern fn arc_dec_i32(handle: ptr) -> void
extern fn arc_dec_string(handle: ptr) -> void
extern fn arc_get_i32(handle: ptr) -> i32
extern fn arc_get_string(handle: ptr) -> string

struct Arc<T> Send Sync {
    handle: ptr
}

fn Arc_clone_applied_i32(arc: Arc<i32>) -> Arc<i32> {
    arc_inc(arc.handle)
    return arc
}

fn Arc_get_applied_i32(arc: Arc<i32>) -> i32 {
    return arc_get_i32(arc.handle)
}

fn Arc_from_i32(value: i32) -> Arc<i32> {
    return Arc<i32> { handle: arc_alloc_i32(value) }
}

fn Arc_from_string(value: string) -> Arc<string> {
    return Arc<string> { handle: arc_alloc_string(value) }
}

fn Arc_get_string(arc: Arc<string>) -> string {
    return arc_get_string(arc.handle)
}

fn Arc_clone_string(arc: Arc<string>) -> Arc<string> {
    arc_inc(arc.handle)
    return arc
}

// Backward-compatible v2.3 surface (Arc_i32 struct).
struct Arc_i32 Send Sync {
    handle: ptr
}

fn Arc_new_i32(value: i32) -> Arc_i32 {
    return Arc_i32 { handle: arc_alloc_i32(value) }
}

fn Arc_clone_i32(arc: Arc_i32) -> Arc_i32 {
    arc_inc(arc.handle)
    return arc
}

fn Arc_get_i32(arc: Arc_i32) -> i32 {
    return arc_get_i32(arc.handle)
}

impl Drop for Arc_i32 {
    fn drop(self) -> void {
        arc_dec_i32(self.handle)
    }
}
