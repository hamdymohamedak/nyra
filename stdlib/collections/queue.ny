import "../vec.ny"

struct Queue_i32 {
    items: ptr
    head: i32
}

fn Queue_i32_new() -> Queue_i32 {
    return Queue_i32 { items: Vec_i32_new(), head: 0 }
}

impl Queue_i32 {
    fn push(self, x: i32) -> Queue_i32 {
        let items = vec_push(self.items, x)
        return Queue_i32 { items: items, head: self.head }
    }

    fn front(self) -> i32 {
        let n = vec_len(self.items)
        if n <= self.head {
            return 0
        }
        return vec_get(self.items, self.head)
    }

    fn advance(self) -> Queue_i32 {
        return Queue_i32 { items: self.items, head: self.head + 1 }
    }

    fn len(self) -> i32 {
        let n = vec_len(self.items)
        if n <= self.head {
            return 0
        }
        return n - self.head
    }
}
