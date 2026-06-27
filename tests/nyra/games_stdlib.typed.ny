import "stdlib/games/grid2d.ny"
import "stdlib/games/ecs.ny"
import "stdlib/games/voxel.ny"

fn test_grid2d() -> i32 {
    let mut grid = Grid2D_i32_new(3, 2, 0)
    grid = grid.set(1, 2, 9)
    if grid.get(1, 2) != 9 {
        return 0
    }
    return 1
}

fn test_ecs() -> i32 {
    let mut world = EcsWorld_new()
    let e0 = EcsWorld_next_id(world)
    world = EcsWorld_advance(world)
    let mut hp = EcsStore_i32_new(0, -1)
    hp = EcsStore_i32_set(hp, e0, 50)
    if EcsStore_i32_get(hp, e0) != 50 {
        return 0
    }
    return 1
}

fn main() -> void {
    if test_grid2d() == 0 {
        print("FAIL grid2d")
        return
    }
    if test_ecs() == 0 {
        print("FAIL ecs")
        return
    }
    print("games_stdlib typed ok")
}
