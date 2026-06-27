#include <stdlib.h>
#include <time.h>

static int nyra_rand_seeded = 0;

static void nyra_rand_seed_once(void) {
    if (!nyra_rand_seeded) {
        srand((unsigned)time(NULL));
        nyra_rand_seeded = 1;
    }
}

int rand_i32(void) {
    nyra_rand_seed_once();
    return rand();
}

int rand_range(int min_val, int max_val) {
    if (max_val <= min_val) {
        return min_val;
    }
    nyra_rand_seed_once();
    return min_val + (rand() % (max_val - min_val + 1));
}

double rand_f64(void) {
    nyra_rand_seed_once();
    return (double)rand() / ((double)RAND_MAX + 1.0);
}

static const char nyra_hex_digits[] = "0123456789abcdef";

char *random_hex(int byte_count) {
    if (byte_count <= 0 || byte_count > 4096) {
        return NULL;
    }
    nyra_rand_seed_once();
    size_t out_len = (size_t)byte_count * 2;
    char *out = (char *)malloc(out_len + 1);
    if (!out) {
        return NULL;
    }
    for (int i = 0; i < byte_count; i++) {
        unsigned char b = (unsigned char)(rand() & 0xff);
        out[i * 2] = nyra_hex_digits[b >> 4];
        out[i * 2 + 1] = nyra_hex_digits[b & 0x0f];
    }
    out[out_len] = '\0';
    return out;
}
