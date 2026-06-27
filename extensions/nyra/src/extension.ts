import * as vscode from "vscode";
import { ensureToolchain, resolveDebugCommand, resolveNyraCommand } from "./toolchain";
import { getLanguageClient, startLanguageClient } from "./lspClient";
import { registerTaskProvider } from "./tasks";
import { registerTestController } from "./tests";

export async function activate(context: vscode.ExtensionContext): Promise<void> {
  const command = resolveNyraCommand(context);
  const toolchain = await ensureToolchain(context);

  startLanguageClient(context, command, toolchain);
  registerTaskProvider(context, command);
  registerTestController(context, command);

  context.subscriptions.push(
    vscode.debug.registerDebugAdapterDescriptorFactory("nyra", {
      createDebugAdapterDescriptor(): vscode.DebugAdapterExecutable {
        const dapPath = resolveDebugCommand(context);
        return new vscode.DebugAdapterExecutable(dapPath, ["dap"]);
      },
    })
  );

  context.subscriptions.push(
    vscode.commands.registerCommand("nyra.showToolchainInfo", async () => {
      const info = await ensureToolchain(context);
      const msg = info.available
        ? `Nyra ${info.version ?? ""} (${info.command})`
        : `Nyra not found (${info.command})`;
      vscode.window.showInformationMessage(msg);
    })
  );
}

export function deactivate(): Thenable<void> | undefined {
  return getLanguageClient()?.stop();
}
