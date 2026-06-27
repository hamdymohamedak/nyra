struct Timer {
    seconds: i32
}

fn Timer_countdown(t){
    let mut remaining = t.seconds
    while remaining > 0 {
        print(`${remaining}...`)
        sleep_ms(1000)
        remaining = remaining - 1
    }
    print("done!")
}

fn Timer_usage(){
    print("usage: timer <seconds>")
}

fn Timer_run(args){
    if args.len() != 1 {
        Timer_usage()
        return 1
    }
    let secs = str_to_i32(args.get(0))
    if secs <= 0 {
        print("seconds must be > 0")
        return 1
    }
    Timer_countdown(Timer { seconds: secs })
    return 0
}
