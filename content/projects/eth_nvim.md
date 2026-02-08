+++
title = "eth.nvim"
description = "A Neovim plugin for navigating Ethereum addresses and transaction hashes to various block explorers."
weight = 11

[extra]
link_to = "https://github.com/0xferrous/eth.nvim"
updated_at = "2025-10-11"
+++

Navigate Ethereum addresses and transaction hashes directly from Neovim to your favorite block explorer. No more copy-paste workflows - just select the identifier and jump straight to Etherscan, Arbiscan, or any configured explorer.

**Features:**
- Smart detection of addresses (42 chars) vs transaction hashes (66 chars)
- Multi-chain support with configurable explorers
- Visual mode integration for precise selection
- Respects your Neovim UI setup (telescope, dressing.nvim, etc.)
- Lightning fast with pure Lua implementation

Perfect for blockchain developers who live in their editor and need quick access to on-chain data.
