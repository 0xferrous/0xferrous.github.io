+++
title = "ansi.nvim"
description = "A Neovim plugin that renders ANSI color escape codes as actual colors in buffers using concealer."
date = "2026-04-26"

[extra]
link_to = "https://github.com/0xferrous/ansi.nvim"
updated_at = "2026-04-26"
+++

A simple Neovim plugin that transforms ugly ANSI escape sequences like `[31mERROR:[0m` into beautiful colored text. Perfect for viewing log files, terminal output, or any text with ANSI color codes.

**Features:**
- Automatically detects and renders ANSI color codes
- Supports multiple color themes (gruvbox, dracula, catppuccin)
- Easy toggle commands
- Works with any file containing ANSI sequences

Built with Lua and leveraging Neovim's powerful extmark system for clean, performant color rendering.
