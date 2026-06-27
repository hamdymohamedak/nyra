import "@root/vendor/bindings/raylib.ny"
import "stdlib/games/voxel.ny"
import "stdlib/games/gfx3d.ny"
import "../../shared/colors.ny"
import "../../shared/window.ny"

const CHUNK = 8

fn Voxel_block_color(kind) {
    if kind == 1 {
        return Gfx_color(80, 160, 60, 0xff)
    }
    if kind == 2 {
        return Gfx_color(120, 90, 50, 0xff)
    }
    return Gfx_color(160, 160, 170, 0xff)
}

fn Voxel_fill_terrain(mut chunk: VoxelChunk_i32) -> VoxelChunk_i32 {
    let mut x = 0
    while x < CHUNK {
        let mut z = 0
        while z < CHUNK {
            let h = 2 + (x + z) % 4
            let mut y = 0
            while y < h {
                let mut kind = 1
                if y == 0 {
                    kind = 2
                }
                chunk = VoxelChunk_i32_set(chunk, x, y, z, kind)
                y = y + 1
            }
            z = z + 1
        }
        x = x + 1
    }
    return chunk
}

fn Voxel_draw_iso(chunk: VoxelChunk_i32, cam_angle: i32) {
    let ox = 200 + cam_angle * 2
    let oy = 320
    let mut bx = 0
    while bx < CHUNK {
        let mut bz = 0
        while bz < CHUNK {
            let mut by = 0
            while by < CHUNK {
                let kind = VoxelChunk_i32_get(chunk, bx, by, bz)
                if kind != 0 {
                    let pt = Gfx3D_isometric_screen(bx * 1.0, by * 1.0, bz * 1.0, 28.0, ox * 1.0, oy * 1.0)
                    let sx = Gfx3D_point2_x(pt)
                    let sy = Gfx3D_point2_y(pt)
                    DrawRectangle(sx, sy, 26, 26, Voxel_block_color(kind))
                    DrawRectangleLines(sx, sy, 26, 26, Gfx_color(30, 30, 30, 0xff))
                }
                by = by + 1
            }
            bz = bz + 1
        }
        bx = bx + 1
    }
}

fn Voxel_camera_orbit(target_x: f64, target_y: f64, target_z: f64, distance: f64, yaw_deg: f64, pitch_deg: f64) -> Camera3D {
    let pos = Gfx3D_orbit_position(target_x, target_y, target_z, distance, yaw_deg, pitch_deg)
    return Camera3D {
        position: Vector3 { x: Gfx3D_vec3_x(pos), y: Gfx3D_vec3_y(pos), z: Gfx3D_vec3_z(pos) },
        target: Vector3 { x: target_x, y: target_y, z: target_z },
        up: Vector3 { x: 0.0, y: 1.0, z: 0.0 },
        fovy: 45.0,
        projection: 0
    }
}

fn Voxel_draw_3d(chunk: VoxelChunk_i32, yaw: i32) {
    let cam = Voxel_camera_orbit(4.0, 2.0, 4.0, 18.0, yaw, 35.0)
    BeginMode3D(cam)
    DrawGrid(10, 1.0)
    let mut bx = 0
    while bx < CHUNK {
        let mut bz = 0
        while bz < CHUNK {
            let mut by = 0
            while by < CHUNK {
                let kind = VoxelChunk_i32_get(chunk, bx, by, bz)
                if kind != 0 {
                    let pos = Vector3 { x: bx * 1.0, y: by * 1.0, z: bz * 1.0 }
                    DrawCube(pos, 0.95, 0.95, 0.95, Voxel_block_color(kind))
                }
                by = by + 1
            }
            bz = bz + 1
        }
        bx = bx + 1
    }
    EndMode3D()
}

fn Voxel_run() {
    Gfx_window_open(800, 600, "Minecraft Clone (voxel)")
    let mut chunk: VoxelChunk_i32 = VoxelChunk_i32_new(CHUNK, 0)
    chunk = Voxel_fill_terrain(chunk)
    let mut cam_angle = 45
    let mut mode_3d = 0
    while !WindowShouldClose() {
        if IsKeyDown(262) {
            cam_angle = cam_angle + 1
        }
        if IsKeyDown(263) {
            cam_angle = cam_angle - 1
        }
        if IsKeyPressed(84) {
            if mode_3d == 0 {
                mode_3d = 1
            } else {
                mode_3d = 0
            }
        }
        Gfx_frame_begin(Gfx_color(120, 180, 0xff, 0xff))
        if mode_3d == 1 {
            Voxel_draw_3d(chunk, cam_angle)
            DrawText("3D cubes  L/R orbit  T toggle iso", 10, 10, 16, Gfx_color(20, 40, 20, 0xff))
        } else {
            Voxel_draw_iso(chunk, cam_angle)
            DrawText("isometric  L/R orbit  T toggle 3D", 10, 10, 16, Gfx_color(20, 40, 20, 0xff))
        }
        Gfx_frame_end()
    }
    Gfx_window_close()
}
