{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

let
  lintelPkgs = inputs.lintel.packages.${pkgs.system};
  lintel = lintelPkgs.default;
  lintel-catalog-builder = lintelPkgs.lintel-catalog-builder;
in
{
  cachix.pull = [ "lintel" ];

  packages = [
    pkgs.git
    pkgs.nodePackages.prettier
    lintel
    lintel-catalog-builder
  ];

  git-hooks.hooks = {
    prettier = {
      enable = true;
      excludes = [ "devenv.lock" ];
    };
    nixfmt = {
      enable = true;
    };
    taplo = {
      enable = true;
    };
    lintel = {
      enable = true;
      name = "lintel";
      entry = "${lintel}/bin/lintel check";
      types_or = [
        "json"
        "yaml"
      ];
    };
  };
}
