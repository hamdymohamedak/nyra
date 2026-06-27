void *channel_new(void) {
    return NULL;
}

void channel_send(void *ch, int value) {
    (void)ch;
    (void)value;
}

int channel_recv(void *ch) {
    (void)ch;
    return 0;
}

void channel_free(void *ch) {
    (void)ch;
}
