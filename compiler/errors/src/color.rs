use std::io::IsTerminal;
use std::sync::Mutex;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ColorChoice {
    Auto,
    Always,
    Never,
}

static COLOR_CHOICE: Mutex<ColorChoice> = Mutex::new(ColorChoice::Auto);

/// Configure terminal colors for diagnostics (`Auto` respects `NO_COLOR` and TTY).
pub fn set_color_choice(choice: ColorChoice) {
    if let Ok(mut guard) = COLOR_CHOICE.lock() {
        *guard = choice;
    }
}

pub fn color_choice() -> ColorChoice {
    COLOR_CHOICE.lock().map(|g| *g).unwrap_or(ColorChoice::Auto)
}

pub(crate) fn colors_enabled() -> bool {
    match color_choice() {
        ColorChoice::Always => true,
        ColorChoice::Never => false,
        ColorChoice::Auto => {
            std::env::var_os("NO_COLOR").is_none() && std::io::stderr().is_terminal()
        }
    }
}

pub(crate) struct Colors {
    pub enabled: bool,
}

impl Colors {
    pub fn new() -> Self {
        Self {
            enabled: colors_enabled(),
        }
    }

    pub fn paint(&self, text: &str, code: &str) -> String {
        if self.enabled {
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

    pub fn error(&self, text: &str) -> String {
        self.paint(text, "\x1b[38;5;9m")
    }

    pub fn warning(&self, text: &str) -> String {
        self.paint(text, "\x1b[38;5;11m")
    }

    pub fn message(&self, text: &str) -> String {
        self.bold(text)
    }

    pub fn location(&self, text: &str) -> String {
        self.paint(text, "\x1b[38;5;14m")
    }

    pub fn line_num(&self, text: &str) -> String {
        self.dim(text)
    }

    pub fn source(&self, text: &str) -> String {
        self.paint(text, "\x1b[38;5;15m")
    }

    pub fn caret(&self, text: &str) -> String {
        self.paint(text, "\x1b[38;5;9m")
    }

    pub fn note_label(&self, text: &str) -> String {
        self.paint(text, "\x1b[38;5;12m")
    }

    pub fn help_label(&self, text: &str) -> String {
        self.paint(text, "\x1b[38;5;10m")
    }

    pub fn code_tag(&self, text: &str) -> String {
        self.paint(text, "\x1b[38;5;13m")
    }
}

impl Default for Colors {
    fn default() -> Self {
        Self::new()
    }
}
