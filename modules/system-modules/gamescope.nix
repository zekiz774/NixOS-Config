{
  pkgs,
  lib,
  ...
}: let
  patch = pkgs.fetchpatch {
    url = "https://patch-diff.githubusercontent.com/raw/ValveSoftware/gamescope/pull/1867.patch";
    hash = "sha256-ONjSInJ7M8niL5xWaNk5Z16ZMcM/A7M7bHTrgCFjrts=";
  };
in {
  nixpkgs.overlays = [
    (final: prev: {
      gamescope = prev.gamescope.overrideAttrs (old: {
        patches = (old.patches or []) ++ [patch];
      });
    })
  ];
}
