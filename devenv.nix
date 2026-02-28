{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

let
  lintelPkgs = inputs.lintel.packages.${pkgs.stdenv.hostPlatform.system};
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

  enterTest = ''
    ${lintel}/bin/lintel check tests/
  '';

  git-hooks.hooks = {
    prettier = {
      enable = true;
      excludes = [ "devenv.lock" ];
    };
    nixfmt = {
      enable = true;
    };
    lintel = {
      enable = true;
      name = "lintel";
      entry = "${lintel}/bin/lintel check";
      types_or = [
        "json"
        "yaml"
        "markdown"
      ];
    };
  };
}
