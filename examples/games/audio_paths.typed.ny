import "stdlib/games/audio.ny"

fn main() -> void {
    let session: GameAudioSession = GameAudioSession_select(GameAudioSession_set_volume(GameAudioSession_new(), 0.8), "level1.ogg")
    print(GameAudio_is_music_path("hit.wav"), session.master_volume, session.current_path)
}
