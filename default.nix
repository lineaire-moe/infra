{ pkgs ? import (import ./npins).nixpkgs {} }:
{
  shell = pkgs.mkShell {
    buildInputs = [
      pkgs.colmena
      pkgs.npins
      pkgs.gitFull
    ];
  };
}
