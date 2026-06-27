// Example: dyn Trait with a struct containing a string field.
trait Greeter {
    fn greet(self) -> string
}

struct NamedGreeter {
    name: string
}

impl Greeter for NamedGreeter {
    fn greet(self) -> string {
        return strcat("hello, ", self.name)
    }
}

fn call_greet(g: dyn Greeter) -> string {
    return g.greet()
}

fn main() {
    let g = NamedGreeter { name: "nyra" }
    print(call_greet(g as dyn Greeter))
}
