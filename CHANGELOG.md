# Changelog

## v0.1.0

- Add Python (Pyright and Ruff), Rust (rust-analyzer), and C/C++ (clangd) support.
- Centralize language servers, formatter preferences, and Treesitter parsers.
- Automatically install configured language servers through Mason.
- Show diagnostic details for the current line, sorted by severity, with English locale settings.
- Add diagnostic search, buffer diagnostic lists, detail toggling, and language server status.
- Refresh diagnostic displays on leaving Insert mode without requiring a save.
- Leave application runtimes and compilers to the user's Docker environment.

Validation: existing-plugin headless checks pass, including server/parser definitions,
automatic installation configuration, diagnostic mappings, and formatting behavior.
External server installation and live diagnostics have not been tested.
