/* Legacy unified Nyra runtime — all modules in one translation unit.
 * Prefer demand-driven linking: nyra-cli links only stdlib/rt/*.c files referenced by the program. */
#include "rt/rt_alloc.c"
#include "rt/rt_strings.c"
#include "rt/rt_fs.c"
#include "rt/rt_io.c"
#include "rt/rt_time.c"
#include "rt/rt_mem.c"
#include "rt/rt_spawn.c"
#include "rt/rt_channel.c"
#include "rt/rt_async.c"
#include "rt/rt_vec.c"
#include "rt/rt_map.c"
#include "rt/rt_arc.c"
