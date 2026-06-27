// f64 basics — price, geo, arithmetic (RFC 0009)

struct Product {
    name: string
    price: f64
}

fn main() -> void {
    let lat: f64 = 30.0444
    let lng: f64 = 31.2357
    print(lat + lng)

    let item = Product { name: "Coffee", price: 4.50 }
  let total = item.price * 1.14
    print(total)
}
