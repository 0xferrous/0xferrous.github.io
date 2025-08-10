+++
title = "Terminal-Wide Ethereum Navigation with Kitty Hints"
date = "2025-08-10"

[taxonomies]
tags = ["terminal", "kitty", "blockchain", "ethereum", "web3", "productivity", "shell"]

[extra]
repo_view = false
comment = true
+++

*Use Kitty's hints to quickly navigate from Ethereum addresses and transaction hashes in your terminal to block explorers*

---

## What Are Kitty Hints?

[Kitty terminal](https://sw.kovidgoyal.net/kitty/) has this incredible feature called "hints" that most people don't know about. Hints aren't clickable links - they're keyboard-driven text selection on steroids. Here's how they work:

1. **Trigger** a hint mode with a keyboard shortcut
2. **Scan** the terminal screen for patterns (URLs, file paths, or custom regex)
3. **Highlight** all matches with letter labels
4. **Select** a match by pressing its label
5. **Execute** an action - copy it, open it, or pipe it to any program

By default, Kitty comes with hints for URLs (`Ctrl+Shift+E`) and file paths (`Ctrl+Shift+P`). But the real power comes from defining your own patterns.

## My Use Case: Ethereum Everywhere

As a blockchain developer, I constantly deal with Ethereum addresses and transaction hashes in my terminal:

```bash
$ forge create Counter --rpc-url $RPC
Contract deployed to: 0x5FbDB2315678afecb367f032d93F642f64180aa3

$ cast send 0x742d35Cc6634C0532925a3b844Bc9e7BB1e4a576 "transfer(address,uint256)" 0x123... 1000
Transaction: 0xdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef
```

The workflow was always: copy → switch to browser → go to Etherscan → paste → search. Repeat 50 times a day.

I thought: what if I could make these identifiers work like URLs? Just highlight and open them?

## Building the Solution

Kitty hints can match custom regex patterns and execute any program with the matched text. Perfect for Ethereum's hex patterns.

Here's how I set it up:

### Step 1: Define the Patterns

I added these to my `~/.config/kitty/kitty.conf`:

```conf
# Quick copy to clipboard
map ctrl+shift+e>a kitten hints --type regex --regex '0x[a-fA-F0-9]{40}' --program @
map ctrl+shift+e>t kitten hints --type regex --regex '0x[a-fA-F0-9]{64}' --program @

# Open in block explorer with menu
map ctrl+shift+e>shift+a kitten hints --type regex --regex '0x[a-fA-F0-9]{40}' --program "launch --type=overlay --title='Select Explorer' ~/scripts/eth-explorer.sh"
map ctrl+shift+e>shift+t kitten hints --type regex --regex '0x[a-fA-F0-9]{64}' --program "launch --type=overlay --title='Select Explorer' ~/scripts/eth-explorer.sh"
```

Breaking this down:
- `ctrl+shift+e` is my Ethereum prefix (like a namespace)
- `>a` and `>t` for addresses and transactions
- `--regex '0x[a-fA-F0-9]{40}'` matches 42-character addresses
- `--regex '0x[a-fA-F0-9]{64}'` matches 66-character transaction hashes
- `--program @` copies to clipboard
- `--program "launch..."` runs my custom script in a floating window

### Step 2: The Explorer Selection Script

Since I work with multiple chains, I needed a way to choose which explorer to use. Here's the script:

```bash
#!/usr/bin/env bash
# ~/scripts/eth-explorer.sh

VALUE="$1"

# Auto-detect type based on length
if [ ${#VALUE} -eq 42 ]; then
    TYPE="address"
elif [ ${#VALUE} -eq 66 ]; then
    TYPE="tx"
else
    echo "Invalid Ethereum value: $VALUE"
    exit 1
fi

# Show explorer menu with fzf
EXPLORER=$(echo -e "Etherscan\nArbiscan\nPolygonscan\nBase\nOptimism\nBSCscan\nAvalanche" | \
    fzf --prompt="Select explorer: " --height=40% --layout=reverse --border)

# Build and open URL
case $EXPLORER in
    Etherscan) URL="https://etherscan.io/$TYPE/$VALUE" ;;
    Arbiscan) URL="https://arbiscan.io/$TYPE/$VALUE" ;;
    Polygonscan) URL="https://polygonscan.com/$TYPE/$VALUE" ;;
    Base) URL="https://basescan.org/$TYPE/$VALUE" ;;
    Optimism) URL="https://optimistic.etherscan.io/$TYPE/$VALUE" ;;
    BSCscan) URL="https://bscscan.com/$TYPE/$VALUE" ;;
    Avalanche) URL="https://snowtrace.io/$TYPE/$VALUE" ;;
    *) exit 1 ;;
esac

xdg-open "$URL"
```

The magic here is Kitty's `launch --type=overlay` - it opens fzf in a floating window without disrupting my terminal layout.

## How It Works in Practice

Let me show you a real example. Here's what happens when I'm debugging a failed transaction:

```bash
$ forge test -vvv
[FAIL. Reason: revert: ERC20: insufficient allowance]
setUp()
  ├─ [24523] → new Token@0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f
  └─ ← 122 bytes of code

testTransfer()
  ├─ [2465] Token::transfer(0x70997970C518123456789012345678901234567890, 1000000000000000000)
  │   └─ ← revert: ERC20: insufficient allowance
  └─ ← revert: ERC20: insufficient allowance
```

I want to check that Token contract on Etherscan:

1. Press `Ctrl+Shift+E`, then `Shift+A`
2. Kitty highlights all addresses in yellow with letter labels
3. I press 'a' to select the Token address
4. A floating window appears with my explorer options
5. I select "Etherscan" with arrow keys
6. Browser opens directly to `https://etherscan.io/address/0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f`

Total time: 3 seconds. No copying, no tab switching, no manual navigation.

## The Workflow Transformation

### Before: The Copy-Paste Dance
- See address in terminal
- Triple-click to select line (hope you get it right)
- Cmd+C to copy
- Switch to browser
- Open new tab
- Navigate to Etherscan
- Click search box
- Cmd+V to paste
- Press Enter

### After: Direct Navigation
- See address
- `Ctrl+Shift+E → Shift+A`
- Select address
- Pick chain
- Done

## Why Kitty Hints Are Perfect for This

1. **Pattern Matching**: Ethereum addresses and tx hashes have distinct patterns - perfect for regex
2. **Visual Feedback**: Highlights make it impossible to select the wrong thing
3. **Keyboard Driven**: No mouse needed, stays in flow
4. **Extensible**: The `--program` flag can run any script with the matched text

## Beyond Ethereum: Other Use Cases

Once you understand hints, you can apply them everywhere:

```conf
# Git commit SHAs
map ctrl+shift+g>c kitten hints --type regex --regex '[a-f0-9]{7,40}' --program "launch --type=overlay ~/scripts/git-show.sh"

# IPFS hashes
map ctrl+shift+i>h kitten hints --type regex --regex 'Qm[1-9A-HJ-NP-Za-km-z]{44}' --program "launch xdg-open https://ipfs.io/ipfs/{}"

# JWT tokens (copy to decode)
map ctrl+shift+j>t kitten hints --type regex --regex 'eyJ[A-Za-z0-9_-]+\.eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+' --program @
```

## Tips for Writing Your Own Hints

1. **Choose Good Prefixes**: I use `ctrl+shift+e` for Ethereum, `ctrl+shift+g` for Git, etc.
2. **Start Simple**: Begin with just copying to clipboard (`--program @`)
3. **Use Overlays**: `launch --type=overlay` keeps your terminal context visible
4. **Test Regex**: Use `echo "test string" | grep -E 'your-regex'` to verify patterns

---

Kitty hints turned my terminal into a smart interface for blockchain development. No more context switching, no more copy-paste errors, just direct navigation from terminal to browser.

The best part? This is just scratching the surface of what hints can do. Once you start thinking in patterns, you'll find uses everywhere.