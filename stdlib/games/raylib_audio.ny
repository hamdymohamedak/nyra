// Raylib music/SFX helpers — requires `link raylib`.
import "audio.ny"

struct Music repr(C) {
    stream: ptr
    frameCount: u32
    looping: bool
    ctxType: i32
    ctxData: ptr
}

extern fn InitAudioDevice() -> void
extern fn CloseAudioDevice() -> void
extern fn IsAudioDeviceReady() -> bool
extern fn SetMasterVolume(volume: f64) -> void
extern fn LoadMusicStream(fileName: string) -> Music
extern fn UnloadMusicStream(music: Music) -> void
extern fn PlayMusicStream(music: Music) -> void
extern fn StopMusicStream(music: Music) -> void
extern fn PauseMusicStream(music: Music) -> void
extern fn ResumeMusicStream(music: Music) -> void
extern fn IsMusicStreamPlaying(music: Music) -> bool
extern fn UpdateMusicStream(music: Music) -> void
extern fn SetMusicVolume(music: Music, volume: f64) -> void

struct RaylibMusicPlayer {
    session: GameAudioSession
    music: Music
    loaded: i32
}

fn RaylibMusicPlayer_new() {
    return RaylibMusicPlayer {
        session: GameAudioSession_new(),
        music: LoadMusicStream(""),
        loaded: 0
    }
}

fn RaylibMusicPlayer_open(player, path) {
    if GameAudio_is_music_path(path) == 0 {
        return player
    }
    if player.loaded != 0 {
        UnloadMusicStream(player.music)
    }
    let music = LoadMusicStream(path)
    return RaylibMusicPlayer {
        session: GameAudioSession_select(player.session, path),
        music: music,
        loaded: 1
    }
}

fn RaylibMusicPlayer_play(player) {
    if player.loaded == 0 {
        return player
    }
    PlayMusicStream(player.music)
    SetMusicVolume(player.music, player.session.master_volume)
    return RaylibMusicPlayer {
        session: GameAudioSession { master_volume: player.session.master_volume, initialized: 1, current_path: player.session.current_path },
        music: player.music,
        loaded: player.loaded
    }
}

fn RaylibMusicPlayer_stop(player) {
    if player.loaded != 0 {
        StopMusicStream(player.music)
    }
    return player
}

fn RaylibMusicPlayer_tick(player) {
    if player.loaded != 0 && IsMusicStreamPlaying(player.music) {
        UpdateMusicStream(player.music)
    }
    return player
}

fn RaylibMusicPlayer_shutdown(player) {
    if player.loaded != 0 {
        UnloadMusicStream(player.music)
    }
    CloseAudioDevice()
    return RaylibMusicPlayer {
        session: player.session,
        music: LoadMusicStream(""),
        loaded: 0
    }
}
