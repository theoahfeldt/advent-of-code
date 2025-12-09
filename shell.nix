with import <nixpkgs> {};
  pkgs.mkShell {
    name = "gleam";
    packages = [
      pkgs.beamMinimal28Packages.erlang
      pkgs.gleam
    ];
    AOC_COOKIE = "53616c7465645f5f958b18a0c9af44c11954c08ae367df57c5635f7241562b46ec5e517b8792767d7e49f898f042532da56600f8b38e8c45c3b88ec9e867ad1a";
  }
