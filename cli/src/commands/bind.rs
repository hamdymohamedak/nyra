use crate::app::args::BindCommands;
use crate::bind::{bind_c, CBindOptions};

pub(crate) fn bind_command(cmd: BindCommands) -> Result<(), String> {
    match cmd {
        BindCommands::Rust {
            crate_name,
            project,
            version,
            export,
            template,
        } => crate::bind::bind_rust(
            &crate_name,
            project,
            version,
            if export.is_empty() {
                None
            } else {
                Some(export)
            },
            template,
        ),
        BindCommands::C {
            header,
            project,
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
        } => bind_c(CBindOptions {
            header,
            project,
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
    }
}
