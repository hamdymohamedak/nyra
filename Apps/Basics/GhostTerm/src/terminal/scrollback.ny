const SCROLLBACK_MAX_LINES = 2000

struct ScrollbackBuffer {
    lines: ptr
}

fn ScrollbackBuffer_new(){
    return ScrollbackBuffer { lines: Vec_str_new() }
}

fn ScrollbackBuffer_trim(buf){
    let len = ScrollbackBuffer_len(buf)
    if len <= SCROLLBACK_MAX_LINES {
        return buf
    }
    let drop = len - SCROLLBACK_MAX_LINES
    let mut out = ScrollbackBuffer_new()
    let mut i = drop
    while i < len {
        out = ScrollbackBuffer_append(out, ScrollbackBuffer_get(buf, i))
        i = i + 1
    }
    Vec_str_free(buf.lines)
    return out
}

fn ScrollbackBuffer_push(buf, line){
    Vec_str_push(buf.lines, line)
    return ScrollbackBuffer_trim(buf)
}

fn ScrollbackBuffer_append(buf, chunk){
    if strlen(chunk) == 0 {
        return buf
    }
    Vec_str_push(buf.lines, chunk)
    return ScrollbackBuffer_trim(buf)
}

struct ScrollbackFeed {
    buf: ScrollbackBuffer
    partial: string
}

fn ScrollbackBuffer_feed(buf: ScrollbackBuffer, partial: string, chunk: string) -> ScrollbackFeed {
    let merged = strcat(partial, chunk)
    let mut out = buf
    let mut rest = merged
    while strlen(rest) > 0 {
        let pos = strstr_pos(rest, "\n")
        if pos < 0 {
            break
        }
        let line = substring(rest, 0, pos)
        out = ScrollbackBuffer_append(out, line)
        rest = substring(rest, pos + 1, strlen(rest) - pos - 1)
    }
    return ScrollbackFeed { buf: out, partial: rest }
}

fn ScrollbackBuffer_len(buf){
    return Vec_str_len(buf.lines)
}

fn ScrollbackBuffer_get(buf, index){
    return Vec_str_get(buf.lines, index)
}

fn ScrollbackBuffer_search(buf, query){
    let len = ScrollbackBuffer_len(buf)
    let mut i = 0
    let mut hits = 0
    while i < len {
        let line = ScrollbackBuffer_get(buf, i)
        if line.contains(query) == 1 {
            hits = hits + 1
        }
        i = i + 1
    }
    return hits
}

fn ScrollbackBuffer_search_print(buf, query){
    let hits = ScrollbackBuffer_search(buf, query)
    print(`scrollback search "${query}": ${hits} matches (Ctrl+Shift+F)`, color: cyan)
    let len = ScrollbackBuffer_len(buf)
    let mut i = 0
    let mut shown = 0
    while i < len && shown < 8 {
        let line = ScrollbackBuffer_get(buf, i)
        if line.contains(query) == 1 {
            print(`  [${i}] ${line}`, color: yellow)
            shown = shown + 1
        }
        i = i + 1
    }
}

fn ScrollbackBuffer_last_n(buf, n){
    let len = ScrollbackBuffer_len(buf)
    if len <= n {
        return 0
    }
    return len - n
}

fn ScrollbackBuffer_clear(buf){
    Vec_str_free(buf.lines)
    return ScrollbackBuffer_new()
}
