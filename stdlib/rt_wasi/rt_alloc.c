#include <stdlib.h>

void heap_free(void *p) {
    if (p) {
        free(p);
    }
}
