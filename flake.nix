{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    flake-utils.url = "github:numtide/flake-utils";

    magma-nvim-src = {
      url = "github:dccsillag/magma-nvim/main";
      flake = false;
    };
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

        buildPlugin = pkgs.vimUtils.buildVimPluginFrom2Nix {
          pname = "magma-nvim";
          version = versionOf inputs.magma-nvim-src;
          src = inputs.magma-nvim-src;
        };

        pythonEnvFn = (ps: with ps; [
          pynvim
          jupyter-client
          ueberzug
          pillow
          cairosvg
          plotly
          # using definition above...
          (callPackage ./pnglatex.nix { })
        ]);

        neovim = (pkgs.neovim.override {
          withPython3 = true;
          extraPython3Packages = pythonEnvFn;
        });
      in
      {
        defaultPackage = neovim;

        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            # pnglatex should be factored into pnglatex.nix
            # but that seems to be currently broken.
            # pnglatex = import ./pnglatex.nix;
            nixpkgs-fmt
          ];
        };
      });
}
