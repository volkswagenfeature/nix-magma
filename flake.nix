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
            ( let 
                # pnglatex should be factored into pnglatex.nix
                # but that seems to be currently broken.
                pnglatex = python39.pkgs.buildPythonPackage rec {
                  pname = "pnglatex";
                  version = "1.1";
                  src = python39.pkgs.fetchPypi {
                    inherit pname version;
                    hash = "sha256-CZUGDUkmttO0BzFYbGFSNMPkWzFC/BW4NmAeOwz4Y9M=";
                  };
                  doCheck = false;
                  meta = with lib; {
                    homepage = "https://github.com/MaT1g3R/pnglatex";
                    description = "a small program that converts LaTeX snippets to png";
                };
              };
              in python39.withPackages(
              ps:[
                ps.pynvim
                ps.jupyter-client
                ps.ueberzug
                ps.pillow
                ps.cairosvg
                ps.plotly
                # using definition above...
                pnglatex
              ]
              )
            )
            nixpkgs-fmt
            any-nix-shell

          ];
        };
      });
}
