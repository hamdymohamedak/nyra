import "vendor/bindings/geom.ny"

fn main() {
    let p = make_point(3, 4)
    print(geom_add(p.x, p.y))
}
