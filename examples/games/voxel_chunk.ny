import "stdlib/games/voxel.ny"

fn main() {
    let mut chunk = VoxelChunk_i32_new(8, 0)
    chunk = VoxelChunk_i32_set(chunk, 0, 0, 0, 2)
    chunk = VoxelChunk_i32_set(chunk, 1, 0, 0, 1)
    print(VoxelChunk_i32_solid_count(chunk), VoxelChunk_i32_visible_face_count(chunk))
}
