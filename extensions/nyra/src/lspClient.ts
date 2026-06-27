import * as vscode from "vscode";
import {
  LanguageClient,
  LanguageClientOptions,
  ServerOptions,
  TransportKind,
} from "vscode-languageclient/node";
import { ToolchainInfo } from "./toolchain";

let client: LanguageClient | undefined;
let statusBar: vscode.StatusBarItem | undefined;

export function startLanguageClient(
  context: vscode.ExtensionContext,
  command: string,
  toolchain: ToolchainInfo
): LanguageClient {
  const config = vscode.workspace.getConfiguration("nyra");
  const serverArgs = config.get<string[]>("languageServerArgs", ["lsp"]);

  const serverOptions: ServerOptions = {
    command,
    args: serverArgs,
    transport: TransportKind.stdio,
  };

  const clientOptions: LanguageClientOptions = {
    documentSelector: [{ scheme: "file", language: "nyra" }],
    synchronize: {
      fileEvents: vscode.workspace.createFileSystemWatcher("**/*.ny"),
    },
  };

  client = new LanguageClient(
    "nyra",
    "Nyra Language Server",
    serverOptions,
    clientOptions
  );
  void client.start();
  context.subscriptions.push({
    dispose: () => {
      void client?.stop();
    },
  });

  if (config.get<boolean>("showVersionInStatusBar", true)) {
    statusBar = vscode.window.createStatusBarItem(
      vscode.StatusBarAlignment.Right,
      100
    );
    statusBar.command = "nyra.showToolchainInfo";
    const ver = toolchain.version ?? "unknown";
    statusBar.text = `$(zap) Nyra ${ver}`;
    statusBar.tooltip = `Nyra toolchain (${command})`;
    statusBar.show();
    context.subscriptions.push(statusBar);
  }

  return client;
}

export function getLanguageClient(): LanguageClient | undefined {
  return client;
}

export function updateStatusBar(text: string): void {
  if (statusBar) {
    statusBar.text = text;
  }
}
