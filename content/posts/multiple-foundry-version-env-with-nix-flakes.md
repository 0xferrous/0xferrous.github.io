+++
title = "Multiple Foundry versions env with Nix Flakes"
date = "2025-10-12"

[taxonomies]
tags = ["development", "foundry", "ethereum", "nixos", "nix", "flakes"]

[extra]
repo_view = true
comment = true
+++

I usually find myself updating my flakes input between `github:shazow/foundry.nix/main` and
`github:shazow/foundry.nix/stable` depending on if i need new feature in nightly but that hasn't
released yet to stable.

I have finally settled on a system that lets me use both of them by installing them both at the
same time.

1. Setup the flake inputs

```nix
{
  inputs = {
    foundry-stable.url = "github:shazow/foundry.nix/stable";
    foundry-nightly.url = "github:shazow/foundry.nix/main";
  };
}
```

2. home-manager module

```nix
{
  lib,
  pkgs,
  # i am able to use this since i pass `inputs` in `extraSpecialArgs`,
  # consult home-manager docs
  inputs, 
  ...
}:
let
  foundry-stable = inputs.foundry-stable.defaultPackage.${pkgs.system};
  foundry-nightly = inputs.foundry-nightly.defaultPackage.${pkgs.system};
  components = [
    "cast"
    "forge"
    "anvil"
    "chisel"
  ];
  foundry-mixed = pkgs.symlinkJoin {
    name = "foundry-mixed";
    paths = [ foundry-stable ];
    nativeBuildInputs = [
      pkgs.makeWrapper
    ];
    postBuild = ''
      ${lib.concatMapStringsSep "\n" (x: "ln -s ${foundry-nightly}/bin/${x} $out/bin/n${x}") components}
    '';
  };
in
{
  home.packages = [ foundry-mixed ];
}
```

This allows me to use stable versions by their regular binary names and
nightly versions are available as `ncast`, `nforge`, etc.
