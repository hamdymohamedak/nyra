#include <stdlib.h>

// Resolved from libnyra_compiler at link time (see compiler-ffi crate).
int nyra_check_file(const char *path);
int nyra_check_source(const char *source, const char *file);
char *nyra_diag_json_file(const char *path);
char *nyra_diag_json_source(const char *source, const char *file);
void nyra_compiler_free(char *ptr);

// Anchor TU for compiler FFI — symbols resolve from libnyra_compiler at link time.
int _nyra_compiler_link_anchor(void) {
    return 0;
}
