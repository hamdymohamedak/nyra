struct FixedStep {
    hz: i32
    accum_ms: f64
    step_ms: f64
}

fn FixedStep_new(hz) {
    let step = 1000.0 / hz
    return FixedStep { hz: hz, accum_ms: 0.0, step_ms: step }
}

fn FixedStep_tick(mut step, frame_ms) {
    step.accum_ms = step.accum_ms + frame_ms
    let mut steps = 0
    while step.accum_ms >= step.step_ms {
        step.accum_ms = step.accum_ms - step.step_ms
        steps = steps + 1
    }
    return steps
}

fn FixedStep_hz(step) {
    return step.hz
}
