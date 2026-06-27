struct Stopwatch {
    start: i64
    laps: ptr
}

fn Stopwatch_new(){
    return Stopwatch { start: instant_now(), laps: Vec_i32_new() }
}

fn Stopwatch_elapsed_ms(sw){
    return instant_elapsed_ms(sw.start)
}

fn Stopwatch_lap(sw){
    let ms = Stopwatch_elapsed_ms(sw)
    Vec_i32_push(sw.laps, ms)
    return sw
}

fn Stopwatch_print_laps(sw){
    let n = Vec_i32_len(sw.laps)
    let mut i = 0
    while i < n {
        print(`lap ${i + 1}: ${Vec_i32_get(sw.laps, i)} ms`)
        i = i + 1
    }
}

fn Stopwatch_free(sw){
    Vec_i32_free(sw.laps)
}

fn Stopwatch_run(){
    let mut sw = Stopwatch_new()
    print("Stopwatch — lap to record, quit to exit")
    let mut running = 1
    while running == 1 {
        let cmd = input("sw> ")
        if strcmp(cmd, "quit") == 0 || strcmp(cmd, "q") == 0 {
            running = 0
        } else {
            if strcmp(cmd, "lap") == 0 {
                sw = Stopwatch_lap(sw)
                print(`elapsed: ${Stopwatch_elapsed_ms(sw)} ms`)
            } else {
                if strcmp(cmd, "laps") == 0 {
                    Stopwatch_print_laps(sw)
                } else {
                    if strcmp(cmd, "time") == 0 {
                        print(`${Stopwatch_elapsed_ms(sw)} ms`)
                    } else {
                        print("commands: lap | laps | time | quit")
                    }
                }
            }
        }
    }
    Stopwatch_free(sw)
}
