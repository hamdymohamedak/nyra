/* Legacy unified WASI runtime — prefer demand-driven linking via stdlib/rt_wasi/*.c */
#include "rt_wasi/rt_common.c"
#include "rt_wasi/rt_alloc.c"
#include "rt_wasi/rt_strings.c"
#include "rt_wasi/rt_io.c"
#include "rt_wasi/rt_time.c"
#include "rt_wasi/rt_mem.c"
#include "rt_wasi/rt_spawn.c"
#include "rt_wasi/rt_async.c"
