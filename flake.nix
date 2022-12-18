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
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            ( let import ./pnglatex
              in python39.withPackages(
              ps:[
                ps.pynvim
                ps.jupyter-client
                ps.ueberzug
                ps.pillow
                ps.cairosvg
                ps.plotly
                #pnglatex is not here

              ]
              )
            )
            nixpkgs-fmt
            any-nix-shell

          ];
        };
      });
}
