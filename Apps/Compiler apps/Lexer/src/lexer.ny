enum LexKind {
    Eof
    Ident
    Number
    String
    LParen
    RParen
    Plus
    Minus
    Star
    Slash
    Comma
    Semicolon
    Eq
}

struct LexToken {
    kind: LexKind
    text: string
    line: i32
    col: i32
}

fn Lexer_is_ident_start(c){
    if c >= 65 && c <= 90 {
        return 1
    }
    if c >= 97 && c <= 122 {
        return 1
    }
    if c == 95 {
        return 1
    }
    return 0
}

fn Lexer_is_ident_part(c){
    if Lexer_is_ident_start(c) == 1 {
        return 1
    }
    if c >= 48 && c <= 57 {
        return 1
    }
    return 0
}

fn Lexer_is_digit(c){
    if c >= 48 && c <= 57 {
        return 1
    }
    return 0
}

fn Lexer_is_space(c){
    if c == 32 || c == 9 || c == 10 || c == 13 {
        return 1
    }
    return 0
}

fn LexKind_name(kind){
    return match kind {
        LexKind.Eof => "EOF"
        LexKind.Ident => "IDENT"
        LexKind.Number => "NUMBER"
        LexKind.String => "STRING"
        LexKind.LParen => "LPAREN"
        LexKind.RParen => "RPAREN"
        LexKind.Plus => "PLUS"
        LexKind.Minus => "MINUS"
        LexKind.Star => "STAR"
        LexKind.Slash => "SLASH"
        LexKind.Comma => "COMMA"
        LexKind.Semicolon => "SEMICOLON"
        LexKind.Eq => "EQ"
    }
}

fn Lexer_token_label(tok){
    return strcat(strcat(LexKind_name(tok.kind), " "), tok.text)
}

fn Lexer_tokenize(source){
    let len = strlen(source)
    let mut out = StrVec_new()
    let mut i = 0
    let mut line = 1
    let mut col = 1
    while i < len {
        let c = char_at(source, i)
        if Lexer_is_space(c) == 1 {
            if c == 10 {
                line = line + 1
                col = 1
            } else {
                col = col + 1
            }
            i = i + 1
        } else {
            if Lexer_is_ident_start(c) == 1 {
                let start = i
                let start_line = line
                let start_col = col
                i = i + 1
                col = col + 1
                while i < len && Lexer_is_ident_part(char_at(source, i)) == 1 {
                    i = i + 1
                    col = col + 1
                }
                let text = substring(source, start, i - start)
                let tok = LexToken { kind: LexKind.Ident, text: text, line: start_line, col: start_col }
                out = out.push(strcat(strcat(strcat(i32_to_string(tok.line), ":"), i32_to_string(tok.col)), strcat(" ", Lexer_token_label(tok))))
            } else {
                if Lexer_is_digit(c) == 1 {
                    let start = i
                    let start_line = line
                    let start_col = col
                    while i < len && Lexer_is_digit(char_at(source, i)) == 1 {
                        i = i + 1
                        col = col + 1
                    }
                    let text = substring(source, start, i - start)
                    let tok = LexToken { kind: LexKind.Number, text: text, line: start_line, col: start_col }
                    out = out.push(strcat(strcat(strcat(i32_to_string(tok.line), ":"), i32_to_string(tok.col)), strcat(" ", Lexer_token_label(tok))))
                } else {
                    if c == 34 {
                        let start_line = line
                        let start_col = col
                        i = i + 1
                        col = col + 1
                        let start = i
                        while i < len {
                            let ch = char_at(source, i)
                            if ch == 34 {
                                break
                            }
                            if ch == 92 {
                                i = i + 1
                                col = col + 1
                            }
                            i = i + 1
                            col = col + 1
                        }
                        let text = substring(source, start, i - start)
                        if i < len {
                            i = i + 1
                            col = col + 1
                        }
                        let tok = LexToken { kind: LexKind.String, text: text, line: start_line, col: start_col }
                        out = out.push(strcat(strcat(strcat(i32_to_string(tok.line), ":"), i32_to_string(tok.col)), strcat(" ", Lexer_token_label(tok))))
                    } else {
                        let start_line = line
                        let start_col = col
                        let mut kind = LexKind.Eof
                        let mut text = ""
                        if c == 40 {
                            kind = LexKind.LParen
                            text = "("
                        } else {
                            if c == 41 {
                                kind = LexKind.RParen
                                text = ")"
                            } else {
                                if c == 43 {
                                    kind = LexKind.Plus
                                    text = "+"
                                } else {
                                    if c == 45 {
                                        kind = LexKind.Minus
                                        text = "-"
                                    } else {
                                        if c == 42 {
                                            kind = LexKind.Star
                                            text = "*"
                                        } else {
                                            if c == 47 {
                                                kind = LexKind.Slash
                                                text = "/"
                                            } else {
                                                if c == 44 {
                                                    kind = LexKind.Comma
                                                    text = ","
                                                } else {
                                                    if c == 59 {
                                                        kind = LexKind.Semicolon
                                                        text = ";"
                                                    } else {
                                                        if c == 61 {
                                                            kind = LexKind.Eq
                                                            text = "="
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        if kind != LexKind.Eof {
                            let tok = LexToken { kind: kind, text: text, line: start_line, col: start_col }
                            out = out.push(strcat(strcat(strcat(i32_to_string(tok.line), ":"), i32_to_string(tok.col)), strcat(" ", Lexer_token_label(tok))))
                        }
                        i = i + 1
                        col = col + 1
                    }
                }
            }
        }
    }
    return out
}

fn Lexer_demo(){
    let sample = "fn add(a, b) { return a + b * 2; }\nlet msg = \"hello\";"
    let tokens = Lexer_tokenize(sample)
    let n = tokens.len()
    let mut i = 0
    while i < n {
        print(tokens.get(i))
        i = i + 1
    }
}

fn Lexer_run(args){
    if args.len() == 0 {
        Lexer_demo()
        return 0
    }
    let path = args.get(0)
    if exists(path) == 0 {
        print(`lexer: ${path}: not found`)
        return 1
    }
    let tokens = Lexer_tokenize(read_file(path))
    let n = tokens.len()
    let mut i = 0
    while i < n {
        print(tokens.get(i))
        i = i + 1
    }
    return 0
}
