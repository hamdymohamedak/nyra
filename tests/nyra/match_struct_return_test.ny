// Match arms returning struct values (comparison dungeon pattern).

enum Tile {
    Floor
    Gold
}

struct Point {
    x: i32
    y: i32
}

fn pick(tile) {
    return match tile {
        Tile.Floor => Point { x: 1, y: 2 }
        Tile.Gold => Point { x: 3, y: 4 }
    }
}

fn main() {
    let p = pick(Tile.Gold)
    print(p.x)
    print(p.y)
}
