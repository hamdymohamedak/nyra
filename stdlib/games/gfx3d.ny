import "../math.ny"

struct Gfx3D_Vec3 {
    x: f64
    y: f64
    z: f64
}

fn Gfx3D_vec3(x, y, z) {
    return Gfx3D_Vec3 { x: x, y: y, z: z }
}

fn Gfx3D_vec3_x(v: Gfx3D_Vec3) {
    return v.x
}

fn Gfx3D_vec3_y(v: Gfx3D_Vec3) {
    return v.y
}

fn Gfx3D_vec3_z(v: Gfx3D_Vec3) {
    return v.z
}

fn Gfx3D_point2_x(pt: Gfx3D_Point2) {
    return pt.x
}

fn Gfx3D_point2_y(pt: Gfx3D_Point2) {
    return pt.y
}

fn Gfx3D_orbit_position(target_x: f64, target_y: f64, target_z: f64, distance: f64, yaw_deg: f64, pitch_deg: f64) -> Gfx3D_Vec3 {
    let yaw = yaw_deg * 3.14159265 / 180.0
    let pitch = pitch_deg * 3.14159265 / 180.0
    let cos_pitch = cos(pitch)
    let dx = distance * cos_pitch * cos(yaw)
    let dy = distance * sin(pitch)
    let dz = distance * cos_pitch * sin(yaw)
    return Gfx3D_Vec3 {
        x: target_x + dx,
        y: target_y + dy,
        z: target_z + dz
    }
}

struct Gfx3D_Point2 {
    x: f64
    y: f64
}

fn Gfx3D_isometric_screen(x: f64, y: f64, z: f64, cell: f64, origin_x: f64, origin_y: f64) -> Gfx3D_Point2 {
    let sx = origin_x + x * cell - z * (cell / 2.0)
    let sy = origin_y - y * cell - z * (cell / 4.0)
    return Gfx3D_Point2 { x: sx, y: sy }
}
