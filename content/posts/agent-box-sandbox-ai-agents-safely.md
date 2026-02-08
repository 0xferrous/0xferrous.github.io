+++
title = "Agent Box: Sandboxing AI Coding Agents"
date = "2026-02-08"

[taxonomies]
tags = ["rust", "docker", "ai", "jujutsu", "git", "nixos"]

[extra]
repo_view = true
comment = true
+++

*A tool for running AI coding agents in disposable containers without risking your host system*

---

## The Problem

AI coding agents like Claude Code and Cursor work best when you give them full autonomy—`--dangerously-skip-permissions`
and all. But that's exactly what makes them dangerous on your host machine. They can execute arbitrary commands,
install packages, modify system files, or accidentally `rm -rf` something critical.

I wanted the benefits of unrestricted agents without the risk, so I built agent-box: a Rust CLI that spawns agents
in Podman containers with full permissions inside, but completely isolated from my host.

## Why Not Just Use Podman Directly?

You could, but you'd quickly run into workflow friction:

- Managing git worktrees or jujutsu workspaces manually
- Mounting the right directories every time
- Passing through environment variables
- Forwarding GPG sockets for commit signing
- Sharing Nix store binaries without copying them into containers
- Remembering 15 different mount flags

Agent-box handles all of this through a layered configuration system. Define your mounts once in `~/.agent-box.toml`,
override per-repository, and compose with profiles for different toolchains.

## The Journey

I started agent-box on January 18th with basic git worktree management. By January 19th I had containers spawning
with workspace mounts. Then the real complexity hit.

### Mount Hell

The first major pain point was mounts. What started as "just bind-mount some paths" turned into:

**Symlink chains**: If you mount `~/mylink` that points to `/tmp/intermediate` which points to `/data/actual`, you
need to mount *all three* or paths break inside the container. Agent-box now automatically resolves and mounts entire
symlink chains.

**Deduplication**: Early on, I'd end up mounting `/nix/store` three times from different configs. Now paths are
canonicalized and deduplicated—if `/nix/store` is already mounted, `/nix/store/package` is redundant.

**Glob patterns**: I wanted to mount `/tmp/kitty-*` to forward Kitty terminal sockets. Added glob support in late
January, which meant handling shell expansion, path existence checks, and making sure globs work with both
`absolute` and `home_relative` mounts.

**Skip patterns**: On NixOS, you *don't* want to mount the entire `/nix/store` into containers—it's massive and
read-only. Added `skip_mounts` with glob support so you can exclude paths like `/nix/store/**` while still
mounting specific subdirectories.

### The Profile System

By January 29th, I realized I was copying the same mount configurations across multiple repos. The profile system
was born:

```toml
[profiles.rust]
env = ["CARGO_HOME=~/.cargo"]
context = """
Rust best practices:
- Run `cargo clippy -- -D warnings`
- Use `?` operator for error propagation
- Prefer iterators over loops
"""

[profiles.rust.mounts.ro]
home_relative = ["~/.cargo/config.toml"]

[profiles.dev]
extends = ["rust"]
ports = ["8080:8080"]
hosts = ["host.docker.internal:host-gateway"]
```

Profiles can extend each other, creating a hierarchy of reusable configurations. Arrays (mounts, env, ports) get
concatenated, and scalar values override. You can define global defaults in `~/.agent-box.toml` and override
per-repository.

### Context for AI Agents

The latest addition (February 7th) was the `context` field. AI agents work better when they understand your project
conventions. Instead of repeating instructions every time, you write them once:

```toml
context = """
This is a web service using axum and sqlx. Architecture:
- src/routes/: HTTP handlers (one file per resource)
- src/models/: Database models
- migrations/: SQL migrations

Always run `just check` before committing (runs fmt, clippy, tests).
"""
```

When you spawn a container, agent-box writes this to `/tmp/context`. Agents can read it to understand your
workflow, coding standards, and project structure. Context strings from profiles get concatenated in resolution
order, so you can layer general guidelines with project-specific instructions.

## Key Technical Decisions

### Jujutsu First, Git Second

I use Jujutsu for version control, so agent-box uses `jj workspace add` for creating isolated workspaces. Git
worktrees are supported via `--git`, but JJ workspaces are the default. This was actually simpler to implement
than I expected—both expose similar directory structures.

### Podman vs Docker

Both are supported via `runtime.backend`, but I use Podman as my daily driver. Podman's user namespace mapping
with `--userns keep-id` is seamless, and overlay mounts (`:O` flag) let containers write to directories without
affecting the host. Docker doesn't support overlays and requires more manual UID mapping, so directories like
`~/.gnupg` need read-write mounts instead.

### Path Translation: `absolute` vs `home_relative`

This tripped me up early on. When you mount a path, where should it appear in the container?

- **`absolute`**: Same path on both sides. `/nix/store` → `/nix/store:/nix/store`
- **`home_relative`**: Host home prefix replaced with container home. `~/.config/git` on host becomes
  `/home/containeruser/.config/git` in the container

This matters for GPG agent forwarding, where sockets live in `/run/user/1000/gnupg/` on the host but need to
appear at `~/.gnupg/S.gpg-agent` in the container.

### Environment Passthrough

Originally I had `env = ["PATH=/usr/bin"]` in my config, which hardcoded paths. That broke when switching between
systems. Added `env_passthrough` in February:

```toml
[runtime]
env_passthrough = ["PATH", "SSH_AUTH_SOCK", "TERM"]
```

Now agent-box reads these from the host environment at spawn time, handling dynamic values correctly.

## The Result

Agent-box is now at a point where I trust it for daily use. Spawning an agent session looks like:

```bash
# Create a new workspace and spawn container
ab spawn -s feature-auth -r my-project -n -p rust -p gpg

# Inside the container:
# - Isolated JJ workspace
# - Nix store mounted via daemon socket
# - GPG agent forwarded for commit signing
# - Context available at /tmp/context
# - Full permissions to install packages, run tests, modify files
```

If the agent does something catastrophic, I can throw away the container and workspace without touching my source
repository. If it works, I review the changes and merge them back.

## Lessons Learned

**Configuration layering is powerful**: Having global defaults, repo-local overrides, and composable profiles
eliminated so much repetition. The validation and resolution debug commands (`ab dbg validate`, `ab dbg resolve`)
saved hours of debugging.

**Path handling is harder than it looks**: Symlinks, globs, canonicalization, home directory translation,
existence checks—there are so many edge cases. The mount system went through five major refactorings before it
felt right.

**Podman's user namespaces just work**: Podman's `--userns keep-id` handles UID mapping automatically, while
Docker requires manual configuration. Overlay mounts are a game-changer for directories like `~/.gnupg` where you
need writes but don't want to affect the host. This is why I use Podman as my main runtime.

**Context makes agents smarter**: Providing project structure and workflow guidelines upfront dramatically
improved agent output. They follow conventions, organize code correctly, and ask better questions.

---

Agent-box is [on GitHub](https://github.com/0xferrous/agent-box) if you want to try it. The README covers
installation, configuration, and usage patterns.

If you're running AI agents on your local machine, give containers a try. The safety and flexibility are worth
the setup.
