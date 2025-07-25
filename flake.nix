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
          ];

          shellHook = ''
            echo "🚀 Development environment for 0xferrous.github.io"
            echo ""
            echo "Available commands:"
            echo "  zola build       - Build the website"
            echo "  zola serve       - Serve locally with hot reload"
            echo "  zola check       - Check for errors"
            echo "  treefmt          - Format all files"
            echo "  gh pr create     - Create GitHub PR"
            echo ""
            echo "Website URL: https://0xferrous.github.io"
            echo "Local dev:   http://127.0.0.1:1111"
            echo ""
            
            echo "📚 Using Recursive fonts from CDN - no local files needed"
            
            # Set up aliases for convenience
            alias serve="zola serve"
            alias build="zola build"
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
      });
}