fn main() {
    let manifest_dir = std::path::PathBuf::from(std::env::var("CARGO_MANIFEST_DIR").unwrap());
    let repo_root = manifest_dir.join("../..");
    let nyra_main = manifest_dir.join("main.ny");
    let status = std::process::Command::new("cargo")
        .current_dir(&repo_root)
        .args([
            "run",
            "--quiet",
            "-p",
            "cli",
            "--",
            "build",
            nyra_main.to_str().unwrap(),
            "-o",
            "libnyra_hello",
            "--cdylib",
        ])
        .status()
        .expect("nyra build");
    if !status.success() {
        panic!("nyra build failed");
    }
    let lib_dir = manifest_dir.join("target/debug");
    println!("cargo:rustc-link-search=native={}", lib_dir.display());
    println!("cargo:rustc-link-lib=dylib=nyra_hello");
}
