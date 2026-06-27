import "stdlib/games/grid2d.ny"
import "stdlib/games/ecs.ny"
import "stdlib/games/voxel.ny"
import "stdlib/games/gfx3d.ny"
import "stdlib/games/audio.ny"

fn test_grid2d() {
    let mut grid: Grid2D_i32 = Grid2D_i32_new(3, 2, 0)
    grid = grid.set(1, 2, 9)
    if grid.get(1, 2) != 9 {
        return 0
    }
    grid = grid.resize(4, 3, -1)
    if grid.get(1, 2) != 9 {
        return 0
    }
    if grid.get(2, 3) != -1 {
        return 0
    }
    return 1
}

fn test_ecs() {
    let mut world = EcsWorld_new()
    let e0 = EcsWorld_next_id(world)
    world = EcsWorld_advance(world)
    let e1 = EcsWorld_next_id(world)
    world = EcsWorld_advance(world)
    let mut hp = EcsStore_i32_new(0, -1)
    hp = EcsStore_i32_set(hp, e0, 100)
    if EcsStore_i32_get(hp, e0) != 100 {
        return 0
    }
    let mut pos = EcsStore_vec2_new(0)
    pos = EcsStore_vec2_set(pos, e0, 4, 8)
    if EcsStore_vec2_get_x(pos, e0) != 4 {
        return 0
    }
    if EcsWorld_count(world) != 2 {
        return 0
    }
    if e1 != 1 {
        return 0
    }
    return 1
}

fn test_voxel() {
    let mut chunk: VoxelChunk_i32 = VoxelChunk_i32_new(4, 0)
    chunk = chunk.set(1, 0, 1, 1)
    chunk = chunk.set(2, 0, 1, 1)
    if chunk.solid_count() != 2 {
        return 0
    }
    if chunk.visible_face_count() < 8 {
        return 0
    }
    return 1
}

fn test_gfx3d() {
    let pos = Gfx3D_orbit_position(0.0, 0.0, 0.0, 10.0, 45.0, 20.0)
    if Gfx3D_vec3_y(pos) <= 0.0 {
        return 0
    }
    let pt = Gfx3D_isometric_screen(1.0, 2.0, 3.0, 32.0, 100.0, 200.0)
    // 100 + 1*32 - 3*16 = 84
    if Gfx3D_point2_x(pt) < 80.0 || Gfx3D_point2_x(pt) > 90.0 {
        return 0
    }
    return 1
}

fn test_audio_paths() {
    if GameAudio_is_music_path("song.ogg") == 0 {
        return 0
    }
    if GameAudio_is_music_path("readme.txt") != 0 {
        return 0
    }
    let session = GameAudioSession_select(GameAudioSession_new(), "track.wav")
    if strcmp(GameAudioSession_path(session), "track.wav") != 0 {
        return 0
    }
    return 1
}

fn main() {
    if test_grid2d() == 0 {
        print("FAIL grid2d")
        return
    }
    if test_ecs() == 0 {
        print("FAIL ecs")
        return
    }
    if test_voxel() == 0 {
        print("FAIL voxel")
        return
    }
    if test_gfx3d() == 0 {
        print("FAIL gfx3d")
        return
    }
    if test_audio_paths() == 0 {
        print("FAIL audio")
        return
    }
    print("games_stdlib ok")
}
