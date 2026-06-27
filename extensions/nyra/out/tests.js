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
exports.registerTestController = registerTestController;
const vscode = __importStar(require("vscode"));
const toolchain_1 = require("./toolchain");
function registerTestController(context, command) {
    const controller = vscode.tests.createTestController("nyra", "Nyra Tests");
    context.subscriptions.push(controller);
    const refresh = async () => {
        controller.items.replace([]);
        const folder = vscode.workspace.workspaceFolders?.[0];
        if (!folder) {
            return;
        }
        const entries = await listTests(command, folder.uri.fsPath);
        const fileMap = new Map();
        for (const entry of entries) {
            let fileItem = fileMap.get(entry.file);
            if (!fileItem) {
                fileItem = controller.createTestItem(entry.file, pathBasename(entry.file), vscode.Uri.file(entry.file));
                controller.items.add(fileItem);
                fileMap.set(entry.file, fileItem);
            }
            const id = `${entry.file}::${entry.name}`;
            const testItem = controller.createTestItem(id, entry.name, vscode.Uri.file(entry.file));
            testItem.range = new vscode.Range(Math.max(0, entry.line - 1), 0, Math.max(0, entry.line - 1), 80);
            fileItem.children.add(testItem);
        }
    };
    context.subscriptions.push(controller.createRunProfile("run", vscode.TestRunProfileKind.Run, async (request, token) => {
        await runTests(controller, command, request, token);
    }, true));
    context.subscriptions.push(vscode.commands.registerCommand("nyra.refreshTests", () => refresh()));
    context.subscriptions.push(vscode.commands.registerCommand("nyra.runAllTests", async () => {
        const folder = vscode.workspace.workspaceFolders?.[0];
        if (!folder) {
            return;
        }
        const term = vscode.window.createTerminal("Nyra Test");
        term.show();
        term.sendText(`${command} test .`);
    }));
    context.subscriptions.push(vscode.workspace.onDidSaveTextDocument((doc) => {
        if (doc.languageId === "nyra") {
            void refresh();
        }
    }));
    void refresh();
    return controller;
}
function pathBasename(p) {
    const parts = p.replace(/\\/g, "/").split("/");
    return parts[parts.length - 1] ?? p;
}
async function listTests(command, cwd) {
    return new Promise((resolve) => {
        const chunks = [];
        const proc = (0, toolchain_1.runNyra)(command, ["test", ".", "--list-json"], cwd);
        proc.stdout.on("data", (d) => chunks.push(String(d)));
        proc.on("close", (code) => {
            if (code !== 0) {
                resolve([]);
                return;
            }
            try {
                resolve(JSON.parse(chunks.join("")));
            }
            catch {
                resolve([]);
            }
        });
        proc.on("error", () => resolve([]));
    });
}
async function runTests(controller, command, request, token) {
    const folder = vscode.workspace.workspaceFolders?.[0];
    if (!folder) {
        return;
    }
    const run = controller.createTestRun(request);
    const queue = collectTests(request);
    if (queue.length === 0) {
        run.appendOutput(`Running all tests…\n`);
        const ok = await execNyra(command, ["test", "."], folder.uri.fsPath, run);
        if (!ok) {
            run.appendOutput("Some tests failed.\n");
        }
        run.end();
        return;
    }
    for (const test of queue) {
        if (token.isCancellationRequested) {
            break;
        }
        const name = test.id.split("::").pop() ?? test.label;
        run.started(test);
        const ok = await execNyra(command, ["test", ".", "--filter", name], folder.uri.fsPath, run);
        if (ok) {
            run.passed(test);
        }
        else {
            run.failed(test, new vscode.TestMessage(`${name} failed`));
        }
    }
    run.end();
}
function collectTests(request) {
    const out = [];
    const include = request.include;
    if (!include) {
        return out;
    }
    for (const item of include) {
        if (item.id.includes("::")) {
            out.push(item);
        }
        else {
            item.children.forEach((child) => out.push(child));
        }
    }
    return out;
}
function execNyra(command, args, cwd, run) {
    return new Promise((resolve) => {
        const proc = (0, toolchain_1.runNyra)(command, args, cwd);
        proc.stdout.on("data", (d) => run.appendOutput(String(d)));
        proc.stderr.on("data", (d) => run.appendOutput(String(d)));
        proc.on("close", (code) => resolve(code === 0));
        proc.on("error", () => resolve(false));
    });
}
//# sourceMappingURL=tests.js.map