+++
title = "Neovim Tabs as Project Workspaces"
date = "2025-09-23"

[taxonomies]
tags = ["neovim", "telescope", "osc7"]

[extra]
repo_view = true
comment = true
+++

I used to keep one terminal tab per repository and spin up more whenever a feature crossed multiple
codebases. Neovim already gives you directory scopes that can encapsulate an entire project per tab,
so I’m trying a new workflow: let Neovim handle the context switching instead of the terminal. With
a small tweak to `telescope-project.nvim` the session stays in sync and I can experiment with
keeping everything inside Neovim.

---

## Directory Scopes 101

Neovim ships with three scoping commands for the working directory:

- `:cd` updates the directory globally. Every window and tab inherits it.
- `:tcd` scopes the change to the current tab. Other tabs keep their roots.
- `:lcd` scopes it just to the active window.

## The Telescope Project Boost

I lean on [`telescope-project.nvim`](https://github.com/nvim-telescope/telescope-project.nvim) to
jump between repositories. My contribution in [PR #176](https://github.com/nvim-telescope/telescope-project.nvim/pull/176)
adds OSC 7 integration: every time I pick a project, Telescope emits an
escape sequence announcing the directory change to the terminal. Any new shell I launch inside that
tab automatically starts in the right project root. No more `cd` gymnastics after the fact.

## My Tab-Per-Project Routine

Here’s how a typical session plays out:

1. Open Neovim in a blank tab.
2. Hit `<C-p>` (mapped to `telescope.extensions.project.project{}`) and pick a repo.
3. Telescope switches me into that project and runs `:tcd` so the tab is scoped correctly.
4. If I need another repo, I run `:tabedit`, hit `<C-p>` again, and choose the next project.
5. Each tab now owns one repository -- buffers, terminals, and commands stay rooted automatically.

Because `:tcd` is tab-local, I can bounce between projects instantly without polluting the other
tabs. Running tests, opening files via `:e`, or spawning a terminal split all happen relative to the
correct repo.

## Configuration Snapshot

```lua
require("telescope").setup({
  extensions = {
    project = {
      base_dirs = { "~/dev", "~/work" },
      enable_osc7 = true,
    },
  },
})

require("telescope").load_extension("project")

vim.keymap.set("n", "<C-p>", function()
  require("telescope").extensions.project.project({})
end, { desc = "Jump to project" })
```

With the OSC 7 support in place, selecting a project also updates the terminal’s current directory.
Tabs become project workspaces, terminals stay in sync, and the whole workflow stays inside Neovim.

## Tips Along the Way

- Run `:tabdo pwd` to confirm each tab’s root when you’re getting started.
- Need a one-off directory tweak? `:lcd` still works for a single window without disturbing the tab.
- Combine this with terminal splits or tools like `toggleterm` and the shell will always inherit the tab’s project directory.

If you’re juggling multiple repositories, let Neovim handle the context instead of your terminal.
Embrace `:cd`, `:tcd`, and `:lcd`, wire them into Telescope, and watch the tab explosion disappear.

