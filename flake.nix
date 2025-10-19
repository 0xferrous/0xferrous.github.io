{
  description = "Development environment for 0xferrous.github.io website";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Import the ipfs-ops package
        ipfs-ops = pkgs.callPackage ./.github/actions/pinata-upload/package.nix { };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Core website building
            zola

            # Formatting and linting
            treefmt
            alejandra  # Nix formatter
            djlint     # HTML template formatter
            prettier   # SCSS/CSS formatter

            # Development tools
            git
            gh         # GitHub CLI

            # Optional but useful
            nodejs     # For any JS tooling if needed
            python3    # For any Python scripts

            # File watching/serving
            watchexec  # File watcher for auto-rebuild

            # Text processing
            fd         # Better find
            ripgrep    # Better grep
            jq         # JSON processor

            # IPFS operations
            ipfs-ops
          ];

          shellHook = ''
            echo "🚀 Development environment for 0xferrous.github.io"
            echo ""
            echo "Available commands:"
            echo "  zola build              - Build with default base URL"
            echo "  nix run .#build-github  - Build for GitHub Pages"
            echo "  nix run .#build-ipfs    - Build for IPFS"
            echo "  zola serve              - Serve locally with hot reload"
            echo "  zola check              - Check for errors"
            echo "  treefmt                 - Format all files"
            echo "  gh pr create            - Create GitHub PR"
            echo "  ipfs-ops                - IPFS operations (upload/IPNS)"
            echo ""
            echo "Website URL: https://0xferrous.github.io"
            echo "Local dev:   http://127.0.0.1:1111"
            echo ""

            echo "📚 Using Recursive fonts from CDN - no local files needed"

            # Set up aliases for convenience
            alias serve="zola serve"
            alias build="zola build"
            alias build-github="nix run .#build-github"
            alias build-ipfs="nix run .#build-ipfs"
            alias check="zola check"
            alias fmt="treefmt"
            alias watch="watchexec -e md,toml,scss,html -- zola build"
          '';

          # Environment variables
          ZOLA_THEME = "apollo";
          EDITOR = "nvim";
        };

        # Additional outputs
        packages.default = pkgs.stdenv.mkDerivation {
          name = "0xferrous-website";
          src = ./.;
          
          buildInputs = [ pkgs.zola ];
          
          buildPhase = ''
            zola build
          '';
          
          installPhase = ''
            cp -r public $out
          '';
        };

        # Development apps
        apps.serve = flake-utils.lib.mkApp {
          drv = pkgs.writeShellScriptBin "serve" ''
            ${pkgs.zola}/bin/zola serve
          '';
        };

        apps.build = flake-utils.lib.mkApp {
          drv = pkgs.writeShellScriptBin "build" ''
            echo "📚 Building site with CDN fonts..."
            ${pkgs.zola}/bin/zola build
          '';
        };

        apps.build-github = flake-utils.lib.mkApp {
          drv = pkgs.writeShellScriptBin "build-github" ''
            echo "📚 Building site for GitHub Pages..."
            ${pkgs.zola}/bin/zola build --base-url "https://0xferrous.github.io"
          '';
        };

        apps.build-ipfs = flake-utils.lib.mkApp {
          drv = pkgs.writeShellScriptBin "build-ipfs" ''
            echo "📚 Building site for IPFS..."
            # IPFS uses relative URLs or specify your IPFS gateway
            ${pkgs.zola}/bin/zola build --base-url "https://0xferrous.eth.limo"
          '';
        };

        apps.ipfs-ops = flake-utils.lib.mkApp {
          drv = ipfs-ops;
        };

        # Export the package
        packages.ipfs-ops = ipfs-ops;
      });
}
