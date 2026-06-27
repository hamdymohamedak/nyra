// Anonymous object literals — zero-types (compiler infers struct shape)

fn main() {
    let family = {
        name: "hamdy",
        age: 20,
        city: "cairo"
    }
    print(family.name)
    print(family.age)
    print(family.city)

    // Same field shape reuses the inferred type
    let other = {
        name: "ada",
        age: 42,
        city: "paris"
    }
    print(other.name)
}
