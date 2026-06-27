// Windows x64 Nt syscall numbers (informational; prefer Win32 APIs or hw_* helpers).
// Raw os_syscall6 is not wired on Windows — use extern + link or stdlib/os modules.

const WIN_NT_CLOSE = 15
const WIN_NT_CREATE_FILE = 85
const WIN_NT_READ_FILE = 6
const WIN_NT_WRITE_FILE = 8
const WIN_NT_QUERY_SYSTEM_INFORMATION = 54
const WIN_NT_DELAY_EXECUTION = 52

// Win32 error codes (common).
const WIN_ERROR_FILE_NOT_FOUND = 2
const WIN_ERROR_ACCESS_DENIED = 5
const WIN_ERROR_INVALID_HANDLE = 6

// VirtualAlloc protection flags (match Windows.h).
const WIN_PAGE_READONLY = 2
const WIN_PAGE_READWRITE = 4
const WIN_PAGE_EXECUTE_READWRITE = 64

const WIN_MEM_COMMIT = 4096
const WIN_MEM_RESERVE = 8192
const WIN_MEM_RELEASE = 32768
