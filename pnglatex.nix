{
  lib
, buildPythonPackage
, fetchPypi 
}:

buildPythonPackage rec {
  pname = "pnglatex";
  version = "1.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-CZUGDUkmttO0BzFYbGFSNMPkWzFC/BW4NmAeOwz4Y9M=";
  };

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/MaT1g3R/pnglatex";
    description = "a small program that converts LaTeX snippets to png";
  };
}
