use std::path::PathBuf;

use compiler::Compiler;
use pkg::verify_project;

use crate::app::args::{PkgBindCommands, PkgCCommands, PkgCommands, StabilityFlags};
use crate::app::session::build;
use crate::bind::{bind_c, CBindOptions};
use crate::c_lib;
use crate::ui::Ui;

pub(crate) fn pkg_command(cmd: PkgCommands) -> Result<(), String> {
    match cmd {
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
