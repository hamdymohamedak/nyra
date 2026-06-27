extern fn os_platform_id() -> i32
extern fn os_platform_name() -> string
extern fn os_page_size() -> i32

const PLATFORM_UNKNOWN = 0
const PLATFORM_LINUX = 1
const PLATFORM_DARWIN = 2
const PLATFORM_WINDOWS = 3

fn platform_name() -> string {
    return os_platform_name()
}

fn platform_id() -> i32 {
    return os_platform_id()
}

fn is_linux() -> bool {
    return os_platform_id() == PLATFORM_LINUX
}

fn is_darwin() -> bool {
    return os_platform_id() == PLATFORM_DARWIN
}

fn is_windows() -> bool {
    return os_platform_id() == PLATFORM_WINDOWS
}

fn page_size() -> i32 {
    return os_page_size()
}
