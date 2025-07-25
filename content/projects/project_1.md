+++
title = "ansi.nvim"
description = "A Neovim plugin to render ANSI escape sequences as actual colors in log files and terminal output."
weight = 1

[extra]
link_to = "https://github.com/0xferrous/ansi.nvim"
+++

A simple Neovim plugin that transforms ugly ANSI escape sequences like `[31mERROR:[0m` into beautiful colored text. Perfect for viewing log files, terminal output, or any text with ANSI color codes.

**Features:**
- Automatically detects and renders ANSI color codes
- Supports multiple color themes (gruvbox, dracula, catppuccin)
- Easy toggle commands
- Works with any file containing ANSI sequences

Built with Lua and leveraging Neovim's powerful extmark system for clean, performant color rendering.
