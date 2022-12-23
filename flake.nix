{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    flake-utils.url = "github:numtide/flake-utils";

    magma-nvim-src = {
      url = "github:WhiteBlackGoose/magma-nvim-goose";
      flake = false;

    };
    jupyterWith = {
      url = "github:tweag/jupyterWith"; 
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    nixvim = {
      url = "github:pta2002/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { nixpkgs, flake-utils, ... }@inputs:
    let
      supportedSystems = [ "x86_64-linux" ];
      eachSystem = flake-utils.lib.eachSystem supportedSystems;
    in
    eachSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        magma-nvim = pkgs.vimUtils.buildVimPluginFrom2Nix {
          pname = "magma-nvim";
          version = builtins.toString  inputs.magma-nvim-src.lastModified;
          src = inputs.magma-nvim-src;
        };

        pythonEnvFn = (ps: with ps; [
          pynvim
          jupyter-client
          ueberzug
          pillow
          cairosvg
          plotly
          ipykernel
          # using definition above...
          (callPackage ./pnglatex.nix { })
        ]);

        neovim = (pkgs.neovim.override {
          withPython3 = true;
          extraPython3Packages = pythonEnvFn;
          configure.packages.myPlugins = with pkgs.vimPlugins; {
            start = [ vim-lastplace vim-nix magma-nvim ]; 
          };
        });

        /*
        ipython = (inputs.jupyterWith.availableKernels.python {
          name = "ipytest";
          displayName = "test kernel";
          inherit system;
        });
        */
      in
      {
        packages.default = neovim;

        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            nixpkgs-fmt
          ];
        };
      });
}
