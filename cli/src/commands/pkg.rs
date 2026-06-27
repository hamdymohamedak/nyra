use std::path::PathBuf;
use std::process::Command;

use compiler::Compiler;
use pkg::{add_dependency, sync_lock_from_mod, verify_project};

use crate::app::args::{PkgBindCommands, PkgCCommands, PkgCommands, StabilityFlags};
use crate::app::session::build;
use crate::bind::{bind_c, CBindOptions};
use crate::c_lib;
use crate::ui::Ui;

pub(crate) fn pkg_command(cmd: PkgCommands) -> Result<(), String> {
    match cmd {
        PkgCommands::Init { path } => {
            let dir = path.unwrap_or_else(|| PathBuf::from("."));
            std::fs::create_dir_all(&dir).map_err(|e| e.to_string())?;
            let mod_path = dir.join("nyra.mod");
            if mod_path.exists() {
                return Err("nyra.mod already exists".into());
            }
            std::fs::write(&mod_path, "module example.local\n\n").map_err(|e| e.to_string())?;

            let main_path = dir.join("main.ny");
            if !main_path.exists() {
                std::fs::write(
                    &main_path,
                    "fn main() {\n    print(\"hello world\")\n}\n",
                )
                .map_err(|e| e.to_string())?;
            }

            let lock = dir.join("nyra.lock");
            let sum = dir.join("nyra.sum");
            sync_lock_from_mod(&mod_path, &lock, &sum)?;
            let ui = Ui::new();
            println!("{}", ui.success("initialized Nyra package"));
            println!("{}", ui.field("nyra.mod", &mod_path.display().to_string()));
            println!("{}", ui.field("main.ny", &main_path.display().to_string()));
            println!("{}", ui.hint("nyra run ."));
            Ok(())
        }
        PkgCommands::Add { module } => {
            add_dependency(&PathBuf::from("."), &module)?;
            let ui = Ui::new();
            if module.starts_with("rust::") {
                let name = module
                    .trim_start_matches("rust::")
                    .split('@')
                    .next()
                    .unwrap_or("");
                println!("{}", ui.success(&format!("added {module}")));
                println!(
                    "{}",
                    ui.field("import", &format!("\"rust/{name}\""))
                );
                println!("{}", ui.field("link", &format!("link-crate {name}")));
            } else {
                println!("{}", ui.success(&format!("added {module}")));
                println!(
                    "{}",
                    ui.field(
                        "import",
                        &format!("\"pkg/{module}/…\"")
                    )
                );
            }
            Ok(())
        }
        PkgCommands::Install { module } => {
            add_dependency(&PathBuf::from("."), &module)?;
            let ui = Ui::new();
            println!("{}", ui.success(&format!("installed {module}")));
            println!("{}", ui.field("updated", "nyra.mod, nyra.lock, nyra.sum"));
            Ok(())
        }
        PkgCommands::Verify { path } => {
            let dir = path.unwrap_or_else(|| PathBuf::from("."));
            verify_project(&dir)?;
            let ui = Ui::new();
            println!(
                "{}  {}",
                ui.success("verify ok"),
                ui.dim(&dir.display().to_string())
            );
            Ok(())
        }
        PkgCommands::Publish {
            name,
            version,
            git_url,
            registry,
            token,
        } => {
            let body = format!(
                r#"{{"name":"{name}","version":"{version}","git_url":"{git_url}","token":"{token}"}}"#
            );
            let status = Command::new("curl")
                .args([
                    "-sf",
                    "-X",
                    "POST",
                    &format!("{registry}/publish"),
                    "-H",
                    "Content-Type: application/json",
                    "-d",
                    &body,
                ])
                .status()
                .map_err(|e| e.to_string())?;
            if !status.success() {
                return Err("publish failed".into());
            }
            let ui = Ui::new();
            println!("{}", ui.success(&format!("published {name} {version}")));
            Ok(())
        }
        PkgCommands::Login { token } => {
            let cred = dirs::home_dir()
                .ok_or("no home")?
                .join(".nyra/credentials");
            std::fs::create_dir_all(cred.parent().unwrap()).map_err(|e| e.to_string())?;
            std::fs::write(&cred, format!("token={token}\n")).map_err(|e| e.to_string())?;
            let ui = Ui::new();
            println!("{}", ui.success("credentials saved"));
            println!("{}", ui.field("path", &cred.display().to_string()));
            Ok(())
        }
        PkgCommands::Build { path, opt, target_args } => {
            let dir = path.unwrap_or_else(|| PathBuf::from("."));
            verify_project(&dir)?;
            build(
                &dir,
                None,
                &opt,
                false,
                false,
                false,
                &target_args,
                &StabilityFlags::default(),
                false,
                false,
                false,
            )
        }
        PkgCommands::Bind { cmd } => match cmd {
            PkgBindCommands::C {
                header,
                link_lib,
                include,
                define,
                output,
                prefix,
                export,
                update_mod,
                stdout,
                shim,
                no_shim,
                path,
            } => bind_c(CBindOptions {
                header,
                project: path,
                link_lib,
                include,
                define,
                output,
                prefix,
                export,
                update_mod,
                stdout,
                generate_shims: shim && !no_shim,
            }),
        },
        PkgCommands::C(cmd) => match cmd {
            PkgCCommands::Add {
                name,
                path,
                no_install,
            } => c_lib::c_add(&name, path, no_install),
            PkgCCommands::Remove { name, path } => c_lib::c_remove(&name, path),
            PkgCCommands::List { path } => c_lib::c_list(path),
        },
        PkgCommands::Prune { path, check } => {
            let dir = path.unwrap_or_else(|| PathBuf::from("."));
            verify_project(&dir)?;
            let result = Compiler::prune_project(&dir, check)?;
            let ui = Ui::new();
            if result.files_changed == 0 {
                println!("{}", ui.success("nothing to prune"));
                return Ok(());
            }
            if check {
                println!(
                    "{}  {} file(s), {} import(s), {} variable(s)",
                    ui.success("prune check"),
                    result.files_changed,
                    result.imports_removed,
                    result.vars_prefixed
                );
                return Err("unused code found (run `nyra pkg prune` to apply)".into());
            }
            println!(
                "{}  {} file(s), {} import(s), {} variable(s)",
                ui.success("pruned unused code"),
                result.files_changed,
                result.imports_removed,
                result.vars_prefixed
            );
            Ok(())
        }
    }
}
