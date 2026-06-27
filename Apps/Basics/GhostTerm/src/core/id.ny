// Monotonic ID generator for tabs, panes, and workspaces.

struct IdGen {
    next: i32
}

fn IdGen_new(){
    return IdGen { next: 1 }
}

fn IdGen_next(gen){
    return IdGen { next: gen.next + 1 }
}

fn IdGen_take(gen){
    return gen.next
}

fn IdGen_peek(gen){
    return gen.next
}

extern fn i32_to_string(n: i32) -> string

fn Id_to_key(id){
    return i32_to_string(id)
}
