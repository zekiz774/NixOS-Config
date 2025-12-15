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
  #nixpkgs.overlays = [
  #  (final: prev: {
  #    gamescope = prev.gamescope.overrideAttrs (old: {
  #      patches = (old.patches or []) ++ [patch];
  #    });
  #  })
  #];
  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "steamos-session-select" ''
      # Treat any "desktop" request as "logout to the greeter"
      case "$1" in
        desktop|plasma|gnome)
          exec loginctl terminate-session "$XDG_SESSION_ID"
          ;;
        *) exit 0 ;;
      esac
    '')
    (writeShellScriptBin "steamos-quit-session" ''
      exec loginctl terminate-session "$XDG_SESSION_ID"
    '')
  ];

  systemd.tmpfiles.rules = [
    "L+ /usr/bin/steamos-session-select - - - - /run/current-system/sw/bin/steamos-session-select"
    "L+ /usr/bin/steamos-quit-session   - - - - /run/current-system/sw/bin/steamos-quit-session"
  ];
}
