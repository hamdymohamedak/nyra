import "../vec.ny"

struct Stack_i32 {
    items: ptr
}

fn Stack_i32_new() -> Stack_i32 {
    return Stack_i32 { items: Vec_i32_new() }
}

impl Stack_i32 {
    fn push(self, x: i32) -> Stack_i32 {
        let items = vec_push(self.items, x)
        return Stack_i32 { items: items }
    }

    fn pop(self) -> i32 {
        return Vec_i32_pop(self.items)
    }

    fn len(self) -> i32 {
        return vec_len(self.items)
    }
}
