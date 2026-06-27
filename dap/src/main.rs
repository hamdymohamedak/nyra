fn main() {
    if let Err(e) = nyra_dap::run_stdio() {
        eprintln!("nyra-dap: {e}");
        std::process::exit(1);
    }
}
