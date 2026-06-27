struct MacroRecorder {
    steps: ptr
    recording: i32
}

fn MacroRecorder_new(){
    return MacroRecorder {
        steps: Vec_str_new()
        recording: 0
    }
}

fn MacroRecorder_start(rec){
    print("macro recording started", color: red)
    return MacroRecorder { steps: rec.steps recording: 1 }
}

fn MacroRecorder_stop(rec){
    print("macro recording stopped", color: dim)
    return MacroRecorder { steps: rec.steps recording: 0 }
}

fn MacroRecorder_record(rec, cmd){
    if rec.recording == 1 {
        Vec_str_push(rec.steps, cmd)
    }
    return rec
}

fn MacroRecorder_play(rec){
    let len = Vec_str_len(rec.steps)
    print(`playing macro (${len} steps):`, color: cyan)
    let mut i = 0
    while i < len {
        let step = Vec_str_get(rec.steps, i)
        print(`  → ${step}`)
        i = i + 1
    }
}

fn MacroRecorder_demo(){
    let mut rec = MacroRecorder_new()
    rec = MacroRecorder_start(rec)
    rec = MacroRecorder_record(rec, "cd ~/project")
    rec = MacroRecorder_record(rec, "cargo build")
    rec = MacroRecorder_record(rec, "cargo run")
    rec = MacroRecorder_stop(rec)
    MacroRecorder_play(rec)
}
