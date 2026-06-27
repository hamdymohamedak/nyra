struct ScrollState {
    offset: i32
    visible_rows: i32
}

fn ScrollState_new(visible_rows: i32) -> ScrollState {
    return ScrollState { offset: 0, visible_rows: visible_rows }
}

fn ScrollState_clamp(mut s: ScrollState, total_rows: i32) -> ScrollState {
    let mut max_off = total_rows - s.visible_rows
    if max_off < 0 {
        max_off = 0
    }
    if s.offset < 0 {
        s.offset = 0
    }
    if s.offset > max_off {
        s.offset = max_off
    }
    return s
}

fn ScrollState_scroll(mut s: ScrollState, delta: i32, total_rows: i32) -> ScrollState {
    s.offset = s.offset + delta
    return ScrollState_clamp(s, total_rows)
}

fn ScrollState_page_up(mut s: ScrollState, total_rows: i32) -> ScrollState {
    s.offset = s.offset - s.visible_rows
    return ScrollState_clamp(s, total_rows)
}

fn ScrollState_page_down(mut s: ScrollState, total_rows: i32) -> ScrollState {
    s.offset = s.offset + s.visible_rows
    return ScrollState_clamp(s, total_rows)
}

fn ScrollState_follow_line(mut s: ScrollState, line: i32, total_rows: i32) -> ScrollState {
    if line < s.offset {
        s.offset = line
    }
    let end = s.offset + s.visible_rows - 1
    if line > end {
        s.offset = line - s.visible_rows + 1
    }
    return ScrollState_clamp(s, total_rows)
}

fn ScrollState_visible_start(s: ScrollState) -> i32 {
    return s.offset
}

fn ScrollState_visible_end(s: ScrollState, total_rows: i32) -> i32 {
    let end = s.offset + s.visible_rows
    if end > total_rows {
        return total_rows
    }
    return end
}
