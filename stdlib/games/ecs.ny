import "../vec.ny"

struct EcsWorld {
    count: i32
}

fn EcsWorld_new() {
    return EcsWorld { count: 0 }
}

fn EcsWorld_count(world: EcsWorld) {
    return world.count
}

fn EcsWorld_next_id(world) {
    return world.count
}

fn EcsWorld_advance(world) {
    return EcsWorld { count: world.count + 1 }
}

struct EcsStore_i32 {
    values: ptr
}

fn EcsStore_i32_new(capacity, fill) {
    let values = Vec_i32_new()
    let mut i = 0
    while i < capacity {
        Vec_i32_push(values, fill)
        i = i + 1
    }
    return EcsStore_i32 { values: values }
}

fn EcsStore_i32_ensure(store, entity, fill) {
    let need = entity + 1
    let mut n = Vec_i32_len(store.values)
    while n < need {
        Vec_i32_push(store.values, fill)
        n = n + 1
    }
    return store
}

fn EcsStore_i32_set(mut store, entity, value) {
    store = EcsStore_i32_ensure(store, entity, 0)
    Vec_i32_set(store.values, entity, value)
    return store
}

fn EcsStore_i32_get(store, entity) {
    if entity < 0 || entity >= Vec_i32_len(store.values) {
        return 0
    }
    return Vec_i32_get(store.values, entity)
}

struct EcsStore_vec2 {
    xs: ptr
    ys: ptr
}

fn EcsStore_vec2_new(capacity) {
    let xs = Vec_i32_new()
    let ys = Vec_i32_new()
    let mut i = 0
    while i < capacity {
        Vec_i32_push(xs, 0)
        Vec_i32_push(ys, 0)
        i = i + 1
    }
    return EcsStore_vec2 { xs: xs, ys: ys }
}

fn EcsStore_vec2_ensure(store, entity) {
    let need = entity + 1
    let mut n = Vec_i32_len(store.xs)
    while n < need {
        Vec_i32_push(store.xs, 0)
        Vec_i32_push(store.ys, 0)
        n = n + 1
    }
    return store
}

fn EcsStore_vec2_set(mut store, entity, x, y) {
    store = EcsStore_vec2_ensure(store, entity)
    Vec_i32_set(store.xs, entity, x)
    Vec_i32_set(store.ys, entity, y)
    return store
}

fn EcsStore_vec2_get_x(store, entity) {
    if entity < 0 || entity >= Vec_i32_len(store.xs) {
        return 0
    }
    return Vec_i32_get(store.xs, entity)
}

fn EcsStore_vec2_get_y(store, entity) {
    if entity < 0 || entity >= Vec_i32_len(store.ys) {
        return 0
    }
    return Vec_i32_get(store.ys, entity)
}

impl Drop for EcsStore_i32 {
    fn drop(self) -> void {
        Vec_i32_free(self.values)
    }
}

impl Drop for EcsStore_vec2 {
    fn drop(self) -> void {
        Vec_i32_free(self.xs)
        Vec_i32_free(self.ys)
    }
}
