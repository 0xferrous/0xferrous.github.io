+++
title = "agent-box"
description = "Sandboxed containers for AI coding agents with disposable Git/Jujutsu workspaces"
weight = 4

[extra]
link_to = "https://github.com/0xferrous/agent-box"
updated_at = "2026-05-04"
+++

A Rust CLI tool that manages isolated container environments for AI coding agents. Combines Git/Jujutsu workspace management with Podman/Docker containers, giving agents unrestricted access inside disposable sandboxes.

**Features:**
- Automatic workspace creation (Jujutsu or Git worktrees)
- Layered configuration with profiles and inheritance
- Smart mount handling with symlink resolution and glob patterns
- Context injection for AI agents via `/tmp/context`
- GPG agent forwarding for commit signing
- Nix store sharing via daemon socket

Built for developers who want the power of autonomous AI agents without the risk of running `--dangerously-skip-permissions` on their host machine. Spawn containers, let agents experiment freely, review changes, and discard or merge - all without touching your source repository.
