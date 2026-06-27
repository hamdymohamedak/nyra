struct CsvRow {
    fields: StrVec
}

fn Csv_split_line(line){
    let mut fields = StrVec_new()
    let len = strlen(line)
    let mut start = 0
    let mut i = 0
    while i <= len {
        let done = if i == len { 1 } else { 0 }
        let comma = if done == 0 && char_at(line, i) == 44 { 1 } else { 0 }
        if done == 1 || comma == 1 {
            let field = substring(line, start, i - start)
            fields = fields.push(field)
            start = i + 1
        }
        i = i + 1
    }
    return fields
}

fn Csv_parse(text){
    return StrVec_from_lines(text)
}

fn Csv_print_row(row, index){
    let n = row.fields.len()
    print(`row ${index}:`)
    let mut i = 0
    while i < n {
        print(`  [${i}] ${row.fields.get(i)}`)
        i = i + 1
    }
}

fn Csv_usage(){
    print("usage: csvread <file.csv>")
}

fn Csv_run(args){
    if args.len() != 1 {
        Csv_usage()
        return 1
    }
    let path = args.get(0)
    if exists(path) == 0 {
        print(`csvread: ${path}: not found`)
        return 1
    }
    let text = read_file(path)
    let lines = Csv_parse(text)
    let n = lines.len()
    let mut i = 0
    while i < n {
        let row = CsvRow { fields: Csv_split_line(lines.get(i)) }
        Csv_print_row(row, i)
        i = i + 1
    }
    return 0
}
