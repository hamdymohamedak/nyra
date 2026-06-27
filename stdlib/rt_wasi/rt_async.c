int async_promise_new(void) {
    return 0;
}

void async_promise_complete(int handle, int value) {
    (void)handle;
    (void)value;
}

int async_await(int handle) {
    (void)handle;
    return 0;
}

int async_poll(int handle) {
    (void)handle;
    return -1;
}

int async_run(int result) {
    return result;
}

void runtime_run(void) {}

int runtime_poll_io(int timeout_ms) {
    (void)timeout_ms;
    return 0;
}

int runtime_executor_tick(int timeout_ms) {
    (void)timeout_ms;
    return 0;
}

int runtime_executor_run_until(int handle, int timeout_ms) {
    (void)timeout_ms;
    return async_poll(handle);
}

int async_sleep_ms(int delay_ms) {
    (void)delay_ms;
    return async_run(0);
}

void async_promise_complete_bool(int handle, int value) {
    (void)handle;
    (void)value;
}

void async_promise_complete_ptr(int handle, void *value) {
    (void)handle;
    (void)value;
}

int async_await_bool(int handle) {
    (void)handle;
    return 0;
}

void *async_await_ptr(int handle) {
    (void)handle;
    return 0;
}

int async_poll_bool(int handle) {
    (void)handle;
    return -1;
}

int async_future_done(int handle) {
    (void)handle;
    return 0;
}

void *async_future_ptr_value(int handle) {
    (void)handle;
    return 0;
}

int async_select2_i32(int h0, int h1, int *out_index) {
    (void)h0;
    (void)h1;
    if (out_index) {
        *out_index = 0;
    }
    return -1;
}

int async_select2_bool(int h0, int h1, int *out_index) {
    (void)h0;
    (void)h1;
    if (out_index) {
        *out_index = 0;
    }
    return -1;
}

void *async_select2_ptr(int h0, int h1, int *out_index) {
    (void)h0;
    (void)h1;
    if (out_index) {
        *out_index = 0;
    }
    return 0;
}

int async_select_i32(int *handles, int count, int *out_index) {
    (void)handles;
    (void)count;
    if (out_index) {
        *out_index = 0;
    }
    return -1;
}

int io_register(int fd, int task_id) {
    (void)fd;
    (void)task_id;
    return -1;
}

int io_wait_once(int timeout_ms) {
    (void)timeout_ms;
    return 0;
}

void spawn(void) {}
