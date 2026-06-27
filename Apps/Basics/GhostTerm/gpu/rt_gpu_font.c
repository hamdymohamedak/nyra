// GPU terminal TTF text (compiled via link-source in gpu/nyra.mod; requires raylib).
#include <raylib.h>
#include <string.h>
#include <unistd.h>

static Font g_font;
static int g_ready;

static int font_path_readable(const char *path) {
    return path && path[0] != '\0' && access(path, R_OK) == 0;
}

static void font_try_load(const char *path) {
    if (g_ready || !font_path_readable(path)) {
        return;
    }
    Font loaded = LoadFont(path);
    if (IsFontValid(loaded)) {
        g_font = loaded;
        g_ready = 1;
    }
}

void gpu_font_init(void) {
    if (g_ready) {
        return;
    }
    const char *paths[] = {
        "/System/Library/Fonts/Menlo.ttc",
        "/Library/Fonts/SF-Mono-Regular.otf",
        "/System/Library/Fonts/SFNSMono.ttf",
        "/System/Library/Fonts/Monaco.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf",
        NULL,
    };
    for (int i = 0; paths[i] != NULL && !g_ready; i++) {
        font_try_load(paths[i]);
    }
}

void gpu_font_draw(const char *text, int x, int y, int font_size, unsigned char r, unsigned char g,
                        unsigned char b, unsigned char a) {
    if (!text) {
        return;
    }
    Color color = {r, g, b, a};
    if (g_ready) {
        Vector2 pos = {(float)x, (float)y};
        DrawTextEx(g_font, text, pos, (float)font_size, 1.0f, color);
        return;
    }
    DrawText(text, x, y, font_size, color);
}

void gpu_font_free(void) {
    if (g_ready) {
        UnloadFont(g_font);
        g_ready = 0;
    }
}
