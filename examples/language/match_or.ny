// Or-patterns: combine multiple match arms that share the same body.
enum Status {
    Ok
    Created
    Accepted
}

fn http_bucket(s: Status) -> i32 {
    match s {
        Status.Ok | Status.Created => 2
        Status.Accepted => 3
    }
}

fn main() {
    print(http_bucket(Status.Ok))
    print(http_bucket(Status.Created))
    print(http_bucket(Status.Accepted))
}
