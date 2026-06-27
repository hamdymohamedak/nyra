import "stdlib/arc.ny"

fn Worker_shared_label(tag: string) -> string {
    let shared = Arc_from_string(tag)
    return Arc_get_string(shared)
}
