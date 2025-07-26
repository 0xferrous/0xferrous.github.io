+++
title = "ansi.nvim: A Neovim Plugin for Beautiful ANSI Color Rendering"
date = "2025-07-25"

[taxonomies]
tags = ["neovim", "plugin", "development", "lua", "ansi", "terminal"]

[extra]
repo_view = true
comment = true
+++

*A simple Neovim plugin to render ANSI escape sequences as actual colors*

---

## The Problem

If you've ever opened a log file in Neovim and seen something like this:

```
[31mERROR:[0m Database connection failed
[33mWARNING:[0m Retrying connection
[32mSUCCESS:[0m Connected successfully
```

Those `[31m` and `[0m` sequences are ANSI escape codes that should render as colors, but instead clutter your editor as raw text.

## What are ANSI Color Codes?

ANSI escape sequences are special character combinations that terminals use to control text formatting and colors. They start with an escape character (`\033` or `\27`) followed by `[` and a series of numbers:

- `[31m` = red text
- `[32m` = green text  
- `[33m` = yellow text
- `[0m` = reset to default

These codes were created in the 1970s and are still widely used today in terminal applications, log files, and command-line tools.

## Neovim's Concealer Feature

Neovim has a powerful feature called "concealer" that can hide text while keeping it in the buffer. It's commonly used in Markdown files to hide markup syntax while showing formatted text.

The concealer works by:
1. Matching text patterns with syntax rules or extmarks
2. Hiding the matched text (making it invisible)
3. Optionally replacing it with different characters

This makes it perfect for hiding ANSI escape sequences while showing their intended colors.

## How ansi.nvim Works

ansi.nvim combines ANSI parsing with Neovim's concealer in a simple two-step process:

1. **Parse and conceal**: Find ANSI sequences and hide them with extmarks
2. **Apply colors**: Color the text between sequences using highlight groups

```lua
-- Hide the escape sequence
vim.api.nvim_buf_set_extmark(bufnr, namespace, line, start_col, {
  end_col = end_col,
  conceal = '', -- Make it invisible
})

-- Color the text
vim.api.nvim_buf_set_extmark(bufnr, namespace, line, text_start, {
  end_col = text_end,
  hl_group = 'AnsiRed', -- Apply red color
})
```

## Installation & Usage

Install with lazy.nvim:

```lua
{
  '0xferrous/ansi.nvim',
  config = function()
    require('ansi').setup({
      theme = 'gruvbox',
      auto_enable = true,
      filetypes = { 'log', 'ansi' },
    })
  end
}
```

### Commands

```vim
:AnsiEnable   " Enable for current buffer
:AnsiDisable  " Disable for current buffer  
:AnsiToggle   " Toggle on/off
```

## Theme Considerations

The colors you see depend on your setup:

- **Neovim colorscheme**: Controls the overall editor appearance
- **Terminal theme**: May affect background colors and contrast
- **ansi.nvim theme**: Maps ANSI codes to specific colors

ansi.nvim includes several built-in themes like `gruvbox`, `dracula`, and `catppuccin` that work well with popular colorschemes. The `terminal` theme attempts to use your actual terminal colors for consistency.

Different combinations can produce very different results - experiment to find what works best for your setup!

---

Check out the [GitHub repository](https://github.com/0xferrous/ansi.nvim) for more details.
