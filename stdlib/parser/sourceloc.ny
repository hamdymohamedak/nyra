import "../strings.ny"

struct SourceLoc {
    file: string
    line: i32
    col: i32
}

fn SourceLoc_new(file, line, col){
    return SourceLoc { file: file, line: line, col: col }
}

fn SourceLoc_zero(){
    return SourceLoc { file: "", line: 1, col: 1 }
}

fn SourceLoc_format(loc){
    return strcat(strcat(strcat(strcat(loc.file, ":"), i32_to_string(loc.line)), ":"), i32_to_string(loc.col))
}

fn SourceLoc_advance(loc, ch){
    if ch == 10 {
        return SourceLoc { file: loc.file, line: loc.line + 1, col: 1 }
    }
    return SourceLoc { file: loc.file, line: loc.line, col: loc.col + 1 }
}

fn SourceLoc_at(loc, label){
    return strcat(strcat(SourceLoc_format(loc), " "), label)
}
