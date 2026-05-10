+++
title = "frcat"
description = "Inspect Frame signer files and extract keys from local data"
date = "2026-04-11"

[extra]
populate_with_readme = true
link_to = "https://github.com/0xferrous/frcat"
updated_at = "2026-04-11"
+++

# frcat

A small CLI for inspecting [Frame](https://frame.sh) signer data.

## What it does

- lists signer files and the addresses they contain
- locates which signer file owns an address

## Usage

```bash
frcat [command]
```

### Commands

#### `frcat ls`
Lists signers that are used by persisted Frame accounts.
This includes signer files as well as signers stored in Frame's persisted config, so hardware accounts like Ledger and Trezor can appear here too.

#### `frcat locate <address>`
Find the signer file that contains an address.
The address must be a valid `0x`-prefixed Ethereum address.

#### `frcat key-of <address>`
Print the private key for an address when the signer type exposes one.
The address must be a valid `0x`-prefixed Ethereum address.
For seed signers, this also prints the derivation path and seed.

> [!NOTE]
> Frame does not store the original imported mnemonic. If a signer was created from a phrase, the mnemonic cannot be recovered from Frame’s persisted data.

## Examples

List signers:

```bash
frcat ls
```
Locate a signer file:

```bash
frcat locate 0x1234567890abcdef1234567890abcdef12345678
```

Show a private key:

```bash
frcat key-of 0x1234567890abcdef1234567890abcdef12345678
```

## Flags

Global flags:

- `--signers-dir` — signer directory path
- `--config-file` — Frame persisted config file for `ls`
- `--password` — password for encrypted signer data
- `--json` — print JSON output

## Defaults

By default, signer data is read from:

- Linux: `~/.config/frame/signers`
- macOS: `~/Library/Application Support/frame/signers`

## Password input

When a password is needed and `--password` is not set, the CLI prompts interactively and hides input when running in a terminal.