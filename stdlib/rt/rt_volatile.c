// Volatile load/store for MMIO — linked when nyra_volatile_* symbols appear in IR.

int volatile_load_i32(void *addr) {
    return *(volatile int *)addr;
}

void volatile_store_i32(void *addr, int value) {
    *(volatile int *)addr = value;
}

unsigned int volatile_load_u32(void *addr) {
    return *(volatile unsigned int *)addr;
}

void volatile_store_u32(void *addr, unsigned int value) {
    *(volatile unsigned int *)addr = value;
}
