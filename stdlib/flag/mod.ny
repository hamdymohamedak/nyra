import "../vec_str.ny"
import "../strings.ny"

extern fn process_exit(code: i32) -> void

struct FlagSet {
    tool: string
    usage: string
    args: StrVec
    positional: StrVec
    verbose: i32
    help_requested: i32
    subcommand: string
}

fn FlagSet_new(tool: string, usage: string) -> FlagSet {
    return FlagSet {
        tool: tool,
        usage: usage,
        args: StrVec_from_argv(1),
        positional: StrVec_new(),
        verbose: 0,
        help_requested: 0,
        subcommand: "",
    }
}

fn Flag_has(args: StrVec, flag: string) -> i32 {
    let n = args.len()
    let mut i = 0
    while i < n {
        if strcmp(args.get(i), flag) == 0 {
            return 1
        }
        i = i + 1
    }
    return 0
}

fn Flag_parse(set: FlagSet) -> FlagSet {
    let n = set.args.len()
    let mut pos = StrVec_new()
    let mut verbose = 0
    let mut help_req = 0
    let mut sub = ""
    let mut i = 0
    while i < n {
        let a = set.args.get(i)
        if strcmp(a, "-v") == 0 || strcmp(a, "--verbose") == 0 {
            verbose = 1
        } else {
            if strcmp(a, "-h") == 0 || strcmp(a, "--help") == 0 {
                help_req = 1
            } else {
                if strlen(a) > 0 && char_at(a, 0) == 45 {
                    print(strcat("flag: unknown option ", a))
                } else {
                    if strlen(sub) == 0 {
                        sub = a
                    }
                    pos = pos.push(a)
                }
            }
        }
        i = i + 1
    }
    return FlagSet {
        tool: set.tool,
        usage: set.usage,
        args: set.args,
        positional: pos,
        verbose: verbose,
        help_requested: help_req,
        subcommand: sub,
    }
}

impl FlagSet {
    fn verbose(self) -> i32 {
        return self.verbose
    }

    fn help(self) -> i32 {
        return self.help_requested
    }

    fn subcommand(self) -> string {
        return self.subcommand
    }

    fn positional(self) -> StrVec {
        return self.positional
    }
}

fn Flag_print_usage(set: FlagSet) -> void {
    print(strcat(strcat("usage: ", set.tool), set.usage))
    print("  -v, --verbose   verbose output")
    print("  -h, --help      show this help")
}

fn Flag_exit_usage(set: FlagSet) -> void {
    Flag_print_usage(set)
    process_exit(2)
}
