import "../strings.ny"

struct Regex {
    handle: ptr
}

extern fn regex_compile(pattern: string) -> ptr
extern fn regex_is_match(handle: ptr, text: string) -> i32
extern fn regex_free(handle: ptr) -> void

fn Regex_new(pattern: string) -> Regex {
    return Regex { handle: regex_compile(pattern) }
}

fn regex_matches(re: Regex, text: string) -> i32 {
    return regex_is_match(re.handle, text)
}

fn regex_replace(re: Regex, text: string, replacement: string) -> string {
    if regex_is_match(re.handle, text) == 0 {
        return text
    }
    return replacement
}

impl Regex {
    fn matches(self, text: string) -> i32 {
        return regex_is_match(self.handle, text)
    }

    fn replace(self, text: string, replacement: string) -> string {
        return regex_replace(self, text, replacement)
    }

    fn captures(self, text: string) -> i32 {
        return regex_is_match(self.handle, text)
    }
}

fn Regex_free(re: Regex) -> void {
    regex_free(re.handle)
}
