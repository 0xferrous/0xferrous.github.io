+++
title = "eth.nvim: A Neovim Plugin for Ethereum Block Explorer Navigation"
date = "2025-07-26"

[taxonomies]
tags = ["neovim", "plugin", "development", "lua", "ethereum", "blockchain", "web3"]

[extra]
repo_view = true
comment = true
+++

*A simple Neovim plugin to navigate Ethereum addresses and transaction hashes to block explorers*

---

## The Problem

If you're a blockchain developer, you've probably found yourself in this situation countless times:

You're reviewing code, logs, or documentation in Neovim and encounter an Ethereum address like:

`0x742d35cc6635c0532925a3b8d3ac25e0b7e4576c`

Or a transaction hash like:

`0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef`

Your next step? Copy the hash, switch to your browser, navigate to Etherscan (or Arbiscan, or Polygonscan...), paste it in the search box, and hit enter. Repeat this dozens of times per day, and it
becomes a productivity killer.

## What are Ethereum Identifiers?

Ethereum uses hexadecimal identifiers for various on-chain entities:

- **Addresses** (42 characters): `0x742d35cc...` - Identify accounts, contracts, and wallets
- **Transaction hashes** (66 characters): `0x1234567890abcdef...` - Unique identifiers for blockchain transactions
- Both start with `0x` and use hexadecimal characters (0-9, a-f)

These identifiers are everywhere in Web3 development - smart contract code, deployment scripts, test files, documentation, and logs.

## Neovim's Visual Selection Power

Neovim's visual selection mode is incredibly powerful for text manipulation. You can:

1. Select text with `v` (character-wise), `V` (line-wise), or `Ctrl-v` (block-wise)
2. Apply operations to the selected text
3. Create custom keymaps that work specifically in visual mode

This makes it perfect for selecting blockchain identifiers and performing actions on them.

## How `eth.nvim` Works

`eth.nvim` leverages Neovim's visual selection and UI capabilities in a streamlined workflow:

1. **Smart detection**: Automatically identifies if selected text is an address or transaction hash
2. **Explorer menu**: Uses `vim.ui.select()` to present configured block explorers
3. **Browser integration**: Opens the selected explorer with the identifier pre-loaded

```lua
-- Detect what type of identifier we have
local eth_type = utils.detect_ethereum_type(selection)
if eth_type == "address" then
  -- It's a 42-character address
elseif eth_type == "tx" then
  -- It's a 66-character transaction hash
end

-- Show explorer selection menu
vim.ui.select(explorer_choices, {
  prompt = string.format("Open %s in:", eth_type)
}, function(choice, idx)
  -- Open URL in browser
  utils.open_url(build_explorer_url(selection, eth_type))
end)
```


## Usage Workflow

1. Select: Visually select an Ethereum address or transaction hash
2. Navigate: Press `<leader>ee` (or your custom keymap)
3. Choose: Pick from your configured block explorers
4. Explore: The URL opens automatically in your default browser

## Multi-Chain Support

Different networks have different block explorers, and `eth.nvim` makes it easy to configure them all:

```lua
require('eth-nvim').setup({
  explorers = {
    -- Ethereum Mainnet
    {
      name = "Etherscan",
      address_url = "https://etherscan.io/address/{address}",
      tx_url = "https://etherscan.io/tx/{tx}",
    },
    -- Arbitrum
    {
      name = "Arbiscan",
      address_url = "https://arbiscan.io/address/{address}",
      tx_url = "https://arbiscan.io/tx/{tx}",
    },
    -- Polygon
    {
      name = "Polygonscan",
      address_url = "https://polygonscan.com/address/{address}",
      tx_url = "https://polygonscan.com/tx/{tx}",
    },
    -- Base
    {
      name = "BaseScan",
      address_url = "https://basescan.org/address/{address}",
      tx_url = "https://basescan.org/tx/{tx}",
    },
  }
})
```

The `{address}` and `{tx}` placeholders get automatically replaced with your selected identifier.
This is also how you can make it navigate to tenderly, openchain, phalcon, etc.

## UI Integration

`eth.nvim` respects your Neovim UI setup by using `vim.ui.select()`, which means:

- telescope.nvim: Shows as a telescope picker
- dressing.nvim: Uses your enhanced UI styling
- fzf-lua: Integrates with fzf interface
- Built-in fallback: Simple numbered list if no UI plugin is installed

This ensures the plugin feels native to your existing Neovim configuration.

## Development Philosophy

`eth.nvim` follows modern Neovim plugin best practices:

- Pure Lua: No VimScript dependencies
- Configurable: Sensible defaults with full customization
- Lightweight: Minimal performance impact
- Well-tested: Comprehensive test suite with 20+ tests
- Cross-platform: Works on Linux, macOS, and Windows

The plugin includes a full Nix development environment with automated testing, linting, and CI/CD through GitHub Actions.

---
Whether you're auditing smart contracts, debugging DeFi protocols, or exploring on-chain data, `eth.nvim` eliminates the friction of jumping between your editor and block explorers.

Check out the repo at [`0xferrous/eth.nvim`](https://github.com/0xferrous/eth.nvim) for installation instructions and advanced configuration options.
