typedef void (*NyraParBody)(int index, void *ctx);

void progress_update(int current, int total, const char *label) {
    (void)current;
    (void)total;
    (void)label;
}

void progress_finish(void) {
}
