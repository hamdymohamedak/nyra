import "@root/vendor/bindings/raylib.ny"
import "../../shared/colors.ny"
import "../../shared/window.ny"
import "../../shared/widgets.ny"

fn Music_is_audio(name) {
    let n = strlen(name)
    if n < 4 {
        return 0
    }
    let tail = substring(name, n - 4, 4)
    if strcmp(tail, ".wav") == 0 {
        return 1
    }
    let mp3 = substring(name, n - 4, 4)
    if strcmp(mp3, ".mp3") == 0 {
        return 1
    }
    let ogg = substring(name, n - 4, 4)
    if strcmp(ogg, ".ogg") == 0 {
        return 1
    }
    return 0
}

fn Music_list_tracks(dir) {
    let lines = list_dir_entries(dir)
    let mut out = StrVec_new()
    let n = lines.len()
    let mut i = 0
    while i < n {
        let name = lines.get(i)
        if Music_is_audio(name) == 1 {
            out.push(name)
        }
        i = i + 1
    }
    return out
}

fn Music_row_clicked(x: i32, y: i32, index: i32) -> i32 {
    return Gui_button_clicked(x, y + index * 30, 360, 26)
}

fn Music_track_count(tracks: StrVec) -> i32 {
    let n = tracks.len()
    if n > 14 {
        return 14
    }
    return n
}

fn Music_draw_tracks(x, y, tracks, selected) {
    let n = tracks.len()
    let mut i = 0
    while i < n && i < 14 {
        let name = tracks.get(i)
        let mut bg = Gfx_color(42, 42, 48, 0xff)
        if strcmp(name, selected) == 0 {
            bg = Gfx_color(90, 70, 160, 0xff)
        }
        Gui_button_draw(x, y + i * 30, 360, 26, name, bg, Gfx_color(60, 60, 70, 0xff), Gfx_color(235, 235, 240, 0xff))
        i = i + 1
    }
}

fn MusicPlayer_run(args) {
    let folder = if args.len() == 1 { args.get(0) } else { "." }
    let mut tracks = Music_list_tracks(folder)
    let mut selected = if tracks.len() > 0 { tracks.get(0) } else { "" }
    let mut status = "Ready"
    let mut loaded = 0
    let mut playing = 0
    let mut music = LoadMusicStream("")
    let bg = Gfx_color(24, 20, 32, 0xff)
    let panel = Gfx_color(18, 16, 24, 0xff)
    let border = Gfx_color(80, 70, 100, 0xff)
    let ink = Gfx_color(235, 230, 245, 0xff)
    let hint = Gfx_color(140, 130, 160, 0xff)
    InitAudioDevice()
    Gfx_window_open(720, 560, "Music Player")
    while !WindowShouldClose() {
        tracks = Music_list_tracks(folder)
        let n = Music_track_count(tracks)
        let mut i = 0
        while i < n {
            if Music_row_clicked(24, 120, i) == 1 {
                selected = tracks.get(i)
                status = strcat("Selected: ", selected)
                loaded = 0
                playing = 0
            }
            i = i + 1
        }
        if Gui_button_clicked(420, 120, 120, 40) == 1 && strlen(selected) > 0 {
            let path = Gui_path_join(folder, selected)
            if exists(path) == 1 {
                if loaded == 1 {
                    UnloadMusicStream(music)
                }
                music = LoadMusicStream(path)
                if IsMusicValid(music) {
                    loaded = 1
                    playing = 0
                    status = strcat("Loaded: ", selected)
                } else {
                    loaded = 0
                    status = strcat("Cannot load: ", selected)
                }
            }
        }
        if Gui_button_clicked(420, 176, 120, 40) == 1 && loaded == 1 {
            if playing == 0 {
                PlayMusicStream(music)
                playing = 1
                status = strcat("Playing: ", selected)
            } else {
                PauseMusicStream(music)
                playing = 0
                status = strcat("Paused: ", selected)
            }
        }
        if Gui_button_clicked(420, 232, 120, 40) == 1 && loaded == 1 {
            StopMusicStream(music)
            playing = 0
            status = strcat("Stopped: ", selected)
        }
        if loaded == 1 {
            UpdateMusicStream(music)
        }
        Gfx_frame_begin(bg)
        Gui_label(24, 20, strcat("folder: ", folder), 16, hint)
        Gui_label(24, 44, status, 14, hint)
        Gui_panel(24, 100, 380, 440, panel, border)
        Music_draw_tracks(24, 120, tracks, selected)
        Gui_button_draw(420, 120, 120, 40, "Load", Gfx_color(70, 130, 200, 0xff), border, ink)
        Gui_button_draw(420, 176, 120, 40, "Play", Gfx_color(120, 70, 180, 0xff), border, ink)
        Gui_button_draw(420, 232, 120, 40, "Stop", Gfx_color(200, 90, 90, 0xff), border, ink)
        if loaded == 1 && playing == 1 {
            Gui_label(420, 280, "Now playing...", 16, Gfx_color(120, 220, 140, 0xff))
        }
        Gfx_frame_end()
    }
    if loaded == 1 {
        UnloadMusicStream(music)
    }
    Gfx_window_close()
    CloseAudioDevice()
    return 0
}
