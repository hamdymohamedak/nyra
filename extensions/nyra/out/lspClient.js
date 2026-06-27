"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.startLanguageClient = startLanguageClient;
exports.getLanguageClient = getLanguageClient;
exports.updateStatusBar = updateStatusBar;
const vscode = __importStar(require("vscode"));
const node_1 = require("vscode-languageclient/node");
let client;
let statusBar;
function startLanguageClient(context, command, toolchain) {
    const config = vscode.workspace.getConfiguration("nyra");
    const serverArgs = config.get("languageServerArgs", ["lsp"]);
    const serverOptions = {
        command,
        args: serverArgs,
        transport: node_1.TransportKind.stdio,
    };
    const clientOptions = {
        documentSelector: [{ scheme: "file", language: "nyra" }],
        synchronize: {
            fileEvents: vscode.workspace.createFileSystemWatcher("**/*.ny"),
        },
    };
    client = new node_1.LanguageClient("nyra", "Nyra Language Server", serverOptions, clientOptions);
    void client.start();
    context.subscriptions.push({
        dispose: () => {
            void client?.stop();
        },
    });
    if (config.get("showVersionInStatusBar", true)) {
        statusBar = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Right, 100);
        statusBar.command = "nyra.showToolchainInfo";
        const ver = toolchain.version ?? "unknown";
        statusBar.text = `$(zap) Nyra ${ver}`;
        statusBar.tooltip = `Nyra toolchain (${command})`;
        statusBar.show();
        context.subscriptions.push(statusBar);
    }
    return client;
}
function getLanguageClient() {
    return client;
}
function updateStatusBar(text) {
    if (statusBar) {
        statusBar.text = text;
    }
}
//# sourceMappingURL=lspClient.js.map