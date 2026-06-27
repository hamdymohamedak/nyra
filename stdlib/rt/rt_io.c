#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if defined(_WIN32)
#include <windows.h>
#else
#include <unistd.h>
#endif

typedef struct {
    char *data;
    size_t len;
    size_t cap;
} NyraStdoutBuf;

static NyraStdoutBuf nyra_stdout_buf = {NULL, 0, 0};

static const size_t NYRA_STDOUT_INIT_CAP = 4096;

static void nyra_stdout_ensure_init(void);

static int nyra_stdout_ensure(size_t need) {
    if (nyra_stdout_buf.len + need <= nyra_stdout_buf.cap) {
        return 0;
    }
    size_t new_cap = nyra_stdout_buf.cap ? nyra_stdout_buf.cap * 2 : NYRA_STDOUT_INIT_CAP;
    while (new_cap < nyra_stdout_buf.len + need) {
        new_cap *= 2;
    }
    char *nd = (char *)realloc(nyra_stdout_buf.data, new_cap);
    if (!nd) {
        return -1;
    }
    nyra_stdout_buf.data = nd;
    nyra_stdout_buf.cap = new_cap;
    return 0;
}

static void nyra_stdout_append(const char *bytes, size_t len) {
    if (!bytes || len == 0) {
        return;
    }
    nyra_stdout_ensure_init();
    if (nyra_stdout_ensure(len) != 0) {
        return;
    }
    memcpy(nyra_stdout_buf.data + nyra_stdout_buf.len, bytes, len);
    nyra_stdout_buf.len += len;
}

void stdout_write_str(const char *s) {
    if (!s) {
        return;
    }
    nyra_stdout_append(s, strlen(s));
}

void stdout_writeln_str(const char *s) {
    stdout_write_str(s);
    nyra_stdout_append("\n", 1);
}

void stdout_write_i32(int n) {
    char tmp[16];
    int i = 0;
    if (n == 0) {
        nyra_stdout_append("0", 1);
        return;
    }
    int neg = 0;
    if (n < 0) {
        neg = 1;
        if (n == -2147483647 - 1) {
            stdout_write_str("-2147483648");
            return;
        }
        n = -n;
    }
    while (n > 0) {
        tmp[i++] = (char)('0' + (n % 10));
        n /= 10;
    }
    if (neg) {
        nyra_stdout_append("-", 1);
    }
    while (i > 0) {
        i--;
        nyra_stdout_append(&tmp[i], 1);
    }
}

void stdout_writeln_i32(int n) {
    stdout_write_i32(n);
    nyra_stdout_append("\n", 1);
}

void stdout_flush(void) {
    if (nyra_stdout_buf.len == 0) {
        return;
    }
#if defined(_WIN32)
    HANDLE out = GetStdHandle(STD_OUTPUT_HANDLE);
    if (out == INVALID_HANDLE_VALUE || out == NULL) {
        nyra_stdout_buf.len = 0;
        return;
    }
    size_t off = 0;
    while (off < nyra_stdout_buf.len) {
        DWORD chunk = (DWORD)(nyra_stdout_buf.len - off);
        if (chunk > 65536) {
            chunk = 65536;
        }
        DWORD written = 0;
        if (!WriteFile(out, nyra_stdout_buf.data + off, chunk, &written, NULL) || written == 0) {
            break;
        }
        off += (size_t)written;
    }
#else
    size_t off = 0;
    while (off < nyra_stdout_buf.len) {
        ssize_t n = write(STDOUT_FILENO, nyra_stdout_buf.data + off, nyra_stdout_buf.len - off);
        if (n < 0) {
            if (errno == EINTR) {
                continue;
            }
            break;
        }
        off += (size_t)n;
    }
#endif
    nyra_stdout_buf.len = 0;
}

int println(const char *msg) {
    stdout_writeln_str(msg);
    return 0;
}

static int nyra_hex_nibble(char c) {
    if (c >= '0' && c <= '9') {
        return c - '0';
    }
    if (c >= 'a' && c <= 'f') {
        return c - 'a' + 10;
    }
    if (c >= 'A' && c <= 'F') {
        return c - 'A' + 10;
    }
    return -1;
}

static int nyra_streq_ci(const char *a, const char *b) {
    if (!a || !b) {
        return 0;
    }
    while (*a && *b) {
        char ca = *a;
        char cb = *b;
        if (ca >= 'A' && ca <= 'Z') {
            ca = (char)(ca - 'A' + 'a');
        }
        if (cb >= 'A' && cb <= 'Z') {
            cb = (char)(cb - 'A' + 'a');
        }
        if (ca != cb) {
            return 0;
        }
        a++;
        b++;
    }
    return *a == '\0' && *b == '\0';
}

static int nyra_parse_hex_byte(const char *s, unsigned *out) {
    int hi = nyra_hex_nibble(s[0]);
    int lo = nyra_hex_nibble(s[1]);
    if (hi < 0 || lo < 0) {
        return 0;
    }
    *out = (unsigned)((hi << 4) | lo);
    return 1;
}

const char *color_ansi(const char *spec) {
    static char seq[48];
    if (!spec || spec[0] == '\0') {
        return "";
    }
    if (spec[0] == '#') {
        size_t len = strlen(spec);
        unsigned r = 0, g = 0, b = 0;
        if (len == 4) {
            int r1 = nyra_hex_nibble(spec[1]);
            int g1 = nyra_hex_nibble(spec[2]);
            int b1 = nyra_hex_nibble(spec[3]);
            if (r1 < 0 || g1 < 0 || b1 < 0) {
                seq[0] = '\0';
                return seq;
            }
            r = (unsigned)(r1 * 17);
            g = (unsigned)(g1 * 17);
            b = (unsigned)(b1 * 17);
        } else if (len == 7) {
            if (!nyra_parse_hex_byte(spec + 1, &r) || !nyra_parse_hex_byte(spec + 3, &g)
                || !nyra_parse_hex_byte(spec + 5, &b)) {
                seq[0] = '\0';
                return seq;
            }
        } else {
            seq[0] = '\0';
            return seq;
        }
        snprintf(seq, sizeof(seq), "\033[38;2;%u;%u;%um", r, g, b);
        return seq;
    }
    {
        size_t len = strlen(spec);
        unsigned r = 0, g = 0, b = 0;
        if (len == 3) {
            int r1 = nyra_hex_nibble(spec[0]);
            int g1 = nyra_hex_nibble(spec[1]);
            int b1 = nyra_hex_nibble(spec[2]);
            if (r1 < 0 || g1 < 0 || b1 < 0) {
                seq[0] = '\0';
                return seq;
            }
            r = (unsigned)(r1 * 17);
            g = (unsigned)(g1 * 17);
            b = (unsigned)(b1 * 17);
            snprintf(seq, sizeof(seq), "\033[38;2;%u;%u;%um", r, g, b);
            return seq;
        }
        if (len == 6) {
            if (!nyra_parse_hex_byte(spec, &r) || !nyra_parse_hex_byte(spec + 2, &g)
                || !nyra_parse_hex_byte(spec + 4, &b)) {
                seq[0] = '\0';
                return seq;
            }
            snprintf(seq, sizeof(seq), "\033[38;2;%u;%u;%um", r, g, b);
            return seq;
        }
    }
    if (strncmp(spec, "rgb(", 4) == 0) {
        unsigned r = 0, g = 0, b = 0;
        if (sscanf(spec + 4, "%u,%u,%u", &r, &g, &b) == 3) {
            snprintf(seq, sizeof(seq), "\033[38;2;%u;%u;%um", r, g, b);
            return seq;
        }
        seq[0] = '\0';
        return seq;
    }
    if (nyra_streq_ci(spec, "reset") || nyra_streq_ci(spec, "default")) {
        return "\033[0m";
    }
    if (nyra_streq_ci(spec, "black")) {
        return "\033[30m";
    }
    if (nyra_streq_ci(spec, "red")) {
        return "\033[31m";
    }
    if (nyra_streq_ci(spec, "green")) {
        return "\033[32m";
    }
    if (nyra_streq_ci(spec, "yellow")) {
        return "\033[33m";
    }
    if (nyra_streq_ci(spec, "blue")) {
        return "\033[34m";
    }
    if (nyra_streq_ci(spec, "magenta") || nyra_streq_ci(spec, "purple")) {
        return "\033[35m";
    }
    if (nyra_streq_ci(spec, "cyan")) {
        return "\033[36m";
    }
    if (nyra_streq_ci(spec, "white")) {
        return "\033[37m";
    }
    if (nyra_streq_ci(spec, "bright_black") || nyra_streq_ci(spec, "gray") || nyra_streq_ci(spec, "grey")) {
        return "\033[90m";
    }
    if (nyra_streq_ci(spec, "bright_red")) {
        return "\033[91m";
    }
    if (nyra_streq_ci(spec, "bright_green")) {
        return "\033[92m";
    }
    if (nyra_streq_ci(spec, "bright_yellow")) {
        return "\033[93m";
    }
    if (nyra_streq_ci(spec, "bright_blue")) {
        return "\033[94m";
    }
    if (nyra_streq_ci(spec, "bright_magenta") || nyra_streq_ci(spec, "bright_purple")) {
        return "\033[95m";
    }
    if (nyra_streq_ci(spec, "bright_cyan")) {
        return "\033[96m";
    }
    if (nyra_streq_ci(spec, "bright_white")) {
        return "\033[97m";
    }
    if (nyra_streq_ci(spec, "bold")) {
        return "\033[1m";
    }
    if (nyra_streq_ci(spec, "dim")) {
        return "\033[2m";
    }
    if (nyra_streq_ci(spec, "italic")) {
        return "\033[3m";
    }
    if (nyra_streq_ci(spec, "underline")) {
        return "\033[4m";
    }
    seq[0] = '\0';
    return seq;
}

const char *ansi_reset(void) {
    return "\033[0m";
}

#define NYRA_STDIN_CHUNK 4096

static char *nyra_empty_string(void) {
    char *out = (char *)malloc(1);
    if (out) {
        out[0] = '\0';
    }
    return out;
}

static size_t nyra_trim_line_end(char *buf, size_t len) {
    while (len > 0 && (buf[len - 1] == '\n' || buf[len - 1] == '\r')) {
        len--;
    }
    buf[len] = '\0';
    return len;
}

char *stdin_read_line(const char *prompt) {
    if (prompt && prompt[0] != '\0') {
        fputs(prompt, stdout);
        fflush(stdout);
    }

    size_t cap = NYRA_STDIN_CHUNK;
    char *buf = (char *)malloc(cap);
    if (!buf) {
        return nyra_empty_string();
    }

#if defined(_WIN32)
    HANDLE in = GetStdHandle(STD_INPUT_HANDLE);
    if (in == INVALID_HANDLE_VALUE || in == NULL) {
        free(buf);
        return nyra_empty_string();
    }
    size_t len = 0;
    while (len + 1 < cap) {
        DWORD chunk = (DWORD)(cap - len - 1);
        if (chunk > 65536) {
            chunk = 65536;
        }
        DWORD got = 0;
        if (!ReadFile(in, buf + len, chunk, &got, NULL) || got == 0) {
            break;
        }
        len += (size_t)got;
        buf[len] = '\0';
        if (memchr(buf, '\n', len) != NULL) {
            break;
        }
        if (len + 1 >= cap) {
            cap *= 2;
            char *next = (char *)realloc(buf, cap);
            if (!next) {
                break;
            }
            buf = next;
        }
    }
#else
    if (fgets(buf, (int)cap, stdin) == NULL) {
        free(buf);
        return nyra_empty_string();
    }
    size_t len = strlen(buf);
    while (len > 0 && (buf[len - 1] != '\n' && buf[len - 1] != '\r') && !feof(stdin)) {
        if (len + 1 >= cap) {
            cap *= 2;
            char *next = (char *)realloc(buf, cap);
            if (!next) {
                break;
            }
            buf = next;
        }
        if (fgets(buf + len, (int)(cap - len), stdin) == NULL) {
            break;
        }
        len = strlen(buf);
    }
#endif
    len = nyra_trim_line_end(buf, len);
    char *out = (char *)realloc(buf, len + 1);
    if (!out) {
        out = buf;
    }
    out[len] = '\0';
    return out;
}

#if defined(_WIN32)
#include <conio.h>
void stdin_set_raw_mode(int enable) {
    (void)enable;
}

int stdin_read_key(void) {
    int c = _getch();
    if (c < 0) {
        return -1;
    }
    return c;
}
#else
#include <termios.h>
#include <unistd.h>

static struct termios nyra_saved_termios;
static int nyra_raw_mode = 0;

void stdin_set_raw_mode(int enable) {
    if (enable) {
        if (tcgetattr(STDIN_FILENO, &nyra_saved_termios) != 0) {
            return;
        }
        struct termios raw = nyra_saved_termios;
        raw.c_lflag &= (tcflag_t) ~(ICANON | ECHO);
        raw.c_cc[VMIN] = 0;
        raw.c_cc[VTIME] = 0;
        tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw);
        nyra_raw_mode = 1;
    } else if (nyra_raw_mode) {
        tcsetattr(STDIN_FILENO, TCSAFLUSH, &nyra_saved_termios);
        nyra_raw_mode = 0;
    }
}

int stdin_read_key(void) {
    unsigned char c = 0;
    if (read(STDIN_FILENO, &c, 1) == 1) {
        return (int)c;
    }
    return -1;
}
#endif

static void nyra_stdout_atexit_flush(void) {
    stdout_flush();
}

static void nyra_stdout_lazy_init(void) {
    static int initialized = 0;
    if (initialized) {
        return;
    }
    initialized = 1;
    atexit(nyra_stdout_atexit_flush);
}

static void nyra_stdout_ensure_init(void) {
    nyra_stdout_lazy_init();
}
