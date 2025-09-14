+++
title = "Foundry trace folding in eth.nvim"
date = "2025-09-14"

[taxonomies]
tags = ["neovim", "plugin", "development", "lua", "ethereum", "blockchain", "web3"]

[extra]
repo_view = true
comment = true
+++

*A new feature added to eth.nvim that allows folding foundry traces' output*

---

## Problem

Some traces are too huge to be comfortable navigating in the terminal even with a pager.
Folding irrelevant subcall traces can make it more manageable. 

## Solution

Ideal solution would be a interactive traces explorer built right into foundry,
but we are going to leave that feature contribution for another day. For now I
solved the problem using neovim's `foldexpr`.

### Commands added

- `:EthTraceFoldEnable` to enable folding 
- `:EthTraceFoldDisable` to disable folding
- `:EthTraceFoldToggle` to toggle folding


### How It Works

- Fold level derives from each line’s left prefix after stripping ANSI:
    - Ignore leading whitespace.
    - Count │ as nesting depth.
    - If the prefix contains ├ or └, add +1 (branch line).
    - Lines without these prefixes get depth 0.
- The plugin sets buffer-local:
    - `foldmethod=expr`
    - `foldexpr=v:lua.require'eth-nvim.trace'.foldexpr(v:lnum)`
    - `foldtext=v:lua.require'eth-nvim.trace'.foldtext()`
- ANSI-safe: strip_ansi removes SGR/CSI sequences so colored traces still fold correctly.

### Quick Start

- Enable in the current buffer: `:EthTraceFoldEnable`
- Toggle: `:EthTraceFoldToggle`
- Use `zM`/`zR` to close/open all folds and `za` to toggle a fold under the cursor.
- Programmatic control:
    - `require('eth-nvim').enable_trace_folds()`
    - `require('eth-nvim').disable_trace_folds()`
    - `require('eth-nvim').toggle_trace_folds()`

Example Depths:

```
  │ ├─ call A → depth 2
  │ │ └─ return → depth 3
  └─ final → depth 1
```
