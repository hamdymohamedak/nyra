use crate::app::args::ToolchainCommands;

pub(crate) fn toolchain_command(cmd: ToolchainCommands) -> Result<(), String> {
    match cmd {
        ToolchainCommands::Install {
            download,
            wasi,
        } => crate::toolchain::install_toolchain(download, wasi),
        ToolchainCommands::Info => {
            crate::toolchain::print_info();
            Ok(())
        }
    }
}
