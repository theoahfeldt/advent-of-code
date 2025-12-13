with import <nixpkgs> {};
  pkgs.mkShell {
    name = "gleam";
    packages = [
      pkgs.beamMinimal28Packages.erlang
      pkgs.gleam
    ];
    shellHook = ''
      source ${toString ./env.sh}
    '';
  }
