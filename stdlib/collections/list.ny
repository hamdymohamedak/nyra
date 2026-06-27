import "../vec.ny"

struct LinkedList_i32 {
    items: ptr
}

fn LinkedList_i32_new() -> LinkedList_i32 {
    return LinkedList_i32 { items: Vec_i32_new() }
}

impl LinkedList_i32 {
    fn push_back(self, x: i32) -> LinkedList_i32 {
        let items = vec_push(self.items, x)
        return LinkedList_i32 { items: items }
    }

    fn len(self) -> i32 {
        return vec_len(self.items)
    }

    fn get(self, i: i32) -> i32 {
        return vec_get(self.items, i)
    }
}
