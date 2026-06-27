import * as vscode from "vscode";

const PROBLEM_MATCHER = "$nyra";

export function registerTaskProvider(
  context: vscode.ExtensionContext,
  command: string
): void {
  context.subscriptions.push(
    vscode.tasks.registerTaskProvider("nyra", {
      provideTasks(): vscode.Task[] {
        const folder = vscode.workspace.workspaceFolders?.[0];
        if (!folder) {
          return [];
        }
        const root = folder.uri.fsPath;
        const defs: Array<{ task: string; args: string[]; group?: vscode.TaskGroup; label?: string }> =
          [
            { task: "build", args: ["build", "."], group: vscode.TaskGroup.Build },
            {
              task: "build-debug",
              label: "Nyra: build (debug)",
              args: ["build", ".", "--debug-symbols"],
              group: vscode.TaskGroup.Build,
            },
            { task: "run", args: ["run", "."], group: vscode.TaskGroup.Build },
            { task: "check", args: ["check", "."], group: vscode.TaskGroup.Build },
            { task: "test", args: ["test", "."], group: vscode.TaskGroup.Test },
            { task: "fmt", args: ["fmt", "--write", "."] },
          ];
        return defs.map(({ task, args, group, label }) => {
          const t = new vscode.Task(
            { type: "nyra", task, path: "." },
            folder,
            label ?? `Nyra: ${task}`,
            "nyra",
            new vscode.ShellExecution(command, args, { cwd: root }),
            PROBLEM_MATCHER
          );
          if (group) {
            t.group = group;
          }
          return t;
        });
      },
      resolveTask(task: vscode.Task): vscode.Task | undefined {
        const folder = vscode.workspace.workspaceFolders?.[0];
        if (!folder || task.definition.type !== "nyra") {
          return undefined;
        }
        const name = task.definition.task as string;
        const taskPath = (task.definition.path as string) ?? ".";
        const argsMap: Record<string, string[]> = {
          build: ["build", taskPath],
          "build-debug": ["build", taskPath, "--debug-symbols"],
          run: ["run", taskPath],
          check: ["check", taskPath],
          test: ["test", taskPath],
          fmt: ["fmt", "--write", taskPath],
        };
        const args = argsMap[name] ?? ["check", taskPath];
        return new vscode.Task(
          task.definition,
          folder,
          task.name ?? `Nyra: ${name}`,
          "nyra",
          new vscode.ShellExecution(command, args, { cwd: folder.uri.fsPath }),
          PROBLEM_MATCHER
        );
      },
    })
  );
}
