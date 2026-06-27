//! Colored, structured CLI output for `nyra pkg` and related commands.

use std::io::IsTerminal;
use std::sync::OnceLock;

use compiler::ColorChoice;

static COLOR: OnceLock<ColorChoice> = OnceLock::new();

pub fn set_cli_color(choice: ColorChoice) {
    let _ = COLOR.set(choice);
}

fn colors_on() -> bool {
    match COLOR.get().copied().unwrap_or(ColorChoice::Auto) {
        ColorChoice::Always => true,
        ColorChoice::Never => false,
        ColorChoice::Auto => {
            std::env::var_os("NO_COLOR").is_none() && std::io::stdout().is_terminal()
        }
    }
}

pub struct Ui {
    on: bool,
}

impl Ui {
    pub fn new() -> Self {
        Self { on: colors_on() }
    }

    fn paint(&self, text: &str, code: &str) -> String {
        if self.on {
            format!("{code}{text}\x1b[0m")
        } else {
            text.to_string()
        }
    }

    pub fn bold(&self, text: &str) -> String {
        self.paint(text, "\x1b[1m")
    }

    pub fn dim(&self, text: &str) -> String {
        self.paint(text, "\x1b[2m")
    }

    pub fn green(&self, text: &str) -> String {
        self.paint(text, "\x1b[38;5;42m")
    }

    pub fn cyan(&self, text: &str) -> String {
        self.paint(text, "\x1b[38;5;51m")
    }

    pub fn blue(&self, text: &str) -> String {
        self.paint(text, "\x1b[38;5;39m")
    }

    pub fn magenta(&self, text: &str) -> String {
        self.paint(text, "\x1b[38;5;141m")
    }

    pub fn yellow(&self, text: &str) -> String {
        self.paint(text, "\x1b[38;5;214m")
    }

    pub fn section(&self, title: &str, subtitle: &str) -> String {
        let sub = if subtitle == "." {
            "./".to_string()
        } else {
            subtitle.to_string()
        };
        format!(
            "\n{}  {}",
            self.bold(&self.magenta(title)),
            self.dim(&sub)
        )
    }

    pub fn success(&self, message: &str) -> String {
        format!("{}  {}", self.green("✔"), self.bold(message))
    }

    pub fn item(&self, name: &str) -> String {
        format!("  {}  {}", self.green("●"), self.bold(name))
    }

    pub fn field(&self, key: &str, value: &str) -> String {
        format!(
            "      {}  {}",
            self.dim(&format!("{key:<8}")),
            self.field_value(value)
        )
    }

    fn field_value(&self, value: &str) -> String {
        if value.starts_with('"') && value.ends_with('"') {
            self.cyan(value)
        } else if value.contains('/') || value.contains('\\') {
            self.blue(value)
        } else {
            self.bold(value)
        }
    }

    pub fn hint(&self, text: &str) -> String {
        format!("  {}  {}", self.dim("tip"), self.cyan(text))
    }

    pub fn cmd(&self, text: &str) -> String {
        self.cyan(text)
    }

    pub fn path(&self, text: &str) -> String {
        self.blue(text)
    }

    pub fn count(&self, n: usize, noun: &str) -> String {
        self.dim(&format!("{n} {noun}"))
    }
}

impl Default for Ui {
    fn default() -> Self {
        Self::new()
    }
}
