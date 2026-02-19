{ pkgs, lib, config, inputs, ... }:

let
  lintel = inputs.lintel.packages.${pkgs.system}.default;
in
{
  cachix.pull = [ "lintel" ];

  packages = [
    pkgs.git
    pkgs.nodePackages.prettier
    lintel
  ];

  git-hooks.hooks.prettier = {
    enable = true;
    excludes = [ "devenv.lock" ];
  };

  git-hooks.hooks.lintel = {
    enable = true;
    name = "lintel";
    entry = "${lintel}/bin/lintel check";
    types_or = [ "json" "yaml" ];
  };
}
