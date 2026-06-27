# Publishing the Nyra VS Code extension

## Prerequisites

1. Install [Node.js](https://nodejs.org/) 18+.
2. Install the VS Code extension manager: `npm i -g @vscode/vsce`.
3. Create a [Visual Studio Marketplace publisher](https://marketplace.visualstudio.com/manage) (e.g. `nyra-lang`).
4. Generate a Personal Access Token with **Marketplace → Manage** scope.

## Build

From the repo root (recommended):

```bash
bash scripts/package-vscode-extension.sh
# Optional: embed nyra binary in the .vsix
BUNDLE_NYRA=1 bash scripts/package-vscode-extension.sh
```

Or manually:

```bash
cd extensions/nyra
cp ../../grammar/nyra.tmLanguage.json syntaxes/
npm install
npm run compile
npm run package
```

This produces `nyra-1.32.0.vsix`.

## Install locally

```bash
code --install-extension nyra-1.32.0.vsix
```

## Publish to Marketplace

```bash
export VSCE_PAT=<your-token>
npm run publish
```

Or one-shot:

```bash
vsce publish -p <token> --no-dependencies
```

## Requirements for users

- `nyra` CLI on `PATH` with `lsp` and `dap` subcommands (or enable `nyra.useBundledToolchain` when packaged with `BUNDLE_NYRA=1`).
- For debugging: `lldb` (macOS) or `gdb` (Linux). Windows uses MSVC/lldb when available.
