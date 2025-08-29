+++
title = "Using mold on NixOS"
date = "2025-08-29"

[taxonomies]
tags = ["development", "rust", "mold", "nixos", "linking"]

[extra]
repo_view = true
comment = true
+++

Simple guide to using [mold](https://github.com/rui314/mold) on NixOS.

---

I struggled to get this right but after a couple days I figured it out.

```nix
{
  home.file.".cargo/config.toml".text = ''
    [target.'cfg(target_os = "linux")']
    linker = "${pkgs.clang}/bin/clang"
    rustflags = ["-C", "link-arg=-fuse-ld=${pkgs.mold-wrapped}/bin/mold"]
  '';
}
```

The gotcha was using the `pkgs.mold-wrapped` instead of `pkgs.mold`. Unwrapped mold doesn't
set the runpath correctly into the built binaries. This is a very NixOS specific issue
because of it not being [FHS](https://refspecs.linuxfoundation.org/FHS_3.0/fhs/index.html) compliant.

With this set you can see the library paths from nix store linked into the binary, use
`readelf -d ./target/debug/my-binary` to verify the runpaths getting set correctly.

You wouldn't need to though, since this works.

Some useful commands when debugging dynamic linking issues:

- `readelf -d ./path/to/binary` will tell you shared lib dependencies and you should also look for `RUNPATH`s.
- `ldd ./path/to/binary` will tell you the shared lib dependencies and their resolved paths.
- `objdump -p ./path/to/binary` can also be useful.

All of them have some similarities in what they show.

You may also want to look at [nix-ld](https://github.com/nix-community/nix-ld) and
[this nix-ld blog post](https://blog.thalheim.io/2022/12/31/nix-ld-a-clean-solution-for-issues-with-pre-compiled-executables-on-nixos/).
