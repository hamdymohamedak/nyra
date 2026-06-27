extern fn time_start(label: string) -> void
extern fn time_end(label: string) -> void
extern fn mem_start(label: string) -> void
extern fn mem_end(label: string) -> void

struct ProfileSession {
    label: string
    active: i32
}

fn profile_start(label: string) -> ProfileSession {
    time_start(label)
    mem_start(label)
    return ProfileSession { label: label, active: 1 }
}

impl ProfileSession {
    fn stop(self) -> void {
        if self.active != 0 {
            time_end(self.label)
            mem_end(self.label)
        }
    }
}

fn profile_time(label: string) -> void {
    time_start(label)
    time_end(label)
}

fn profile_memory(label: string) -> void {
    mem_start(label)
    mem_end(label)
}
