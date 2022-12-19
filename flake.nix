{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    let
      supportedSystems = [ "aarch64-darwin" "x86_64-linux" ];
      eachSystem = flake-utils.lib.eachSystem supportedSystems;
    in
    eachSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        pythonenv = pkgs.python3.withPackages (
          ps: [
            ps.pynvim
            ps.jupyter-client
            ps.ueberzug
            ps.pillow
            ps.cairosvg
            ps.plotly
            # using definition above...
            (ps.callPackage ./pnglatex.nix { })
          ]
        );
        neovim = (pkgs.neovim.override {
          configure = {
            withPython3 = false;
            python3Env = pythonenv;
            customRC = "
            "

          };
        });
      in
      {
        defaultPackage = neovim;
        devShell = pkgs.mkShell {
          buildInputs = [
            # pnglatex should be factored into pnglatex.nix
            # but that seems to be currently broken.
            # pnglatex = import ./pnglatex.nix;
            neovim
            pythonenv
            pkgs.nixpkgs-fmt
            pkgs.any-nix-shell
          ];
        };
      });
}
