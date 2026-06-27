// GhostTerm — shared enums and constants for the terminal engine.

enum TabKind {
    Standard,
    Private,
    Sandbox,
    Disposable,
}

enum SplitDirection {
    Horizontal,
    Vertical,
}

enum PaneKind {
    Leaf,
    SplitH,
    SplitV,
}

enum ShellKind {
    Bash,
    Zsh,
    Fish,
    PowerShell,
    Cmd,
    Nushell,
    Wsl,
    Ssh,
    Custom,
}

enum ThemeMode {
    Dark,
    Light,
    Transparent,
    Custom,
}

enum FeatureFlag {
    Search,
    History,
    Autocomplete,
    SyntaxHighlight,
    GpuRender,
    SshManager,
    PortForward,
    ProcessManager,
    ClipboardHistory,
    CommandPalette,
    Extensions,
    AiExplain,
    AiFix,
    Notifications,
    FilePreview,
    Recording,
    Broadcast,
    Macro,
    ScratchPad,
    Bookmarks,
    PerformanceMonitor,
    DownloadManager,
}

const MAX_TABS = 256
const MAX_PANES = 512
const MAX_IDENTITIES = 32
const MAX_SHELL_PROFILES = 32
const MAX_WORKSPACES = 16
const SESSION_VERSION = 1

const APP_NAME = "GhostTerm"
const SESSION_DIR = ".ghostterm/sessions"
const CONFIG_DIR = ".ghostterm"
