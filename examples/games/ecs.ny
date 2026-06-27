import "stdlib/games/ecs.ny"

fn main() {
    let mut world = EcsWorld_new()
    let e0 = EcsWorld_next_id(world)
    world = EcsWorld_advance(world)
    let mut hp = EcsStore_i32_new(0, 0)
    hp = EcsStore_i32_set(hp, e0, 100)
    print(EcsStore_i32_get(hp, e0), world.count)
}
