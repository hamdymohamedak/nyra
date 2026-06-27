fn Quote_quotes(){
    let mut v = StrVec_new()
    v = v.push("The only way to do great work is to love what you do.")
    v = v.push("Stay hungry, stay foolish.")
    v = v.push("Simplicity is the soul of efficiency.")
    v = v.push("Code is like humor. When you have to explain it, it's bad.")
    v = v.push("First, solve the problem. Then, write the code.")
    return v
}

fn Quote_pick(quotes){
    let n = quotes.len()
    let idx = random_range(0, n - 1)
    return quotes.get(idx)
}

fn Quote_run(){
    let quotes = Quote_quotes()
    print("Random Quote Generator — press Enter for a quote, quit to exit")
    let mut running = 1
    while running == 1 {
        let cmd = input("quote> ")
        if strcmp(cmd, "quit") == 0 || strcmp(cmd, "q") == 0 {
            running = 0
        } else {
            print(Quote_pick(quotes))
        }
    }
}
