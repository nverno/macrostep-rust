# Interactive macro expander for Rust

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

This package implements the
[macrostep](https://github.com/emacsorphanage/macrostep) interface to expand
Rust macros interactively using rust-analyzer and lsp-rust from
[lsp-mode](https://github.com/emacs-lsp/lsp-mode) to get the macroexpansion.

## Usage

Add `macrostep-rust-hook` to your rust mode hook, eg.

```elisp
(add-hook 'rust-mode-hook #'macrostep-rust-hook)
```

And call `macrostep-expand` with point on or inside a rust macro.
