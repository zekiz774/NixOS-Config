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
  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "steamos-session-select" ''
      #!/usr/bin/env bash
      set -euo pipefail

      if [ $# -ge 1 ]; then
        target="$1"
      else
        target=desktop
      fi

      case "$target" in
        desktop|plasma|gnome)
          # Find greeter session and switch to it (go back to GDM on tty1)
          GREETER_SID=""
          for sid in $(loginctl list-sessions --no-legend | awk '{print $1}'); do
            if [ "$(loginctl show-session "$sid" -p Class --value 2>/dev/null)" = "greeter" ]; then
              GREETER_SID="$sid"; break
            fi
          done
          [ -n "$GREETER_SID" ] && loginctl activate "$GREETER_SID" || true

          # Then terminate our current session (Gamescope on tty2); do it in background
          ( sleep 0.2; loginctl terminate-session "$XDG_SESSION_ID" ) >/dev/null 2>&1 &
          exit 0
          ;;
        *)
          exit 0
          ;;
      esac
    '')

    (writeShellScriptBin "steamos-quit-session" ''
      #!/usr/bin/env bash
      set -euo pipefail

      GREETER_SID=""
      for sid in $(loginctl list-sessions --no-legend | awk '{print $1}'); do
        if [ "$(loginctl show-session "$sid" -p Class --value 2>/dev/null)" = "greeter" ]; then
          GREETER_SID="$sid"; break
        fi
      done
      [ -n "$GREETER_SID" ] && loginctl activate "$GREETER_SID" || true
      ( sleep 0.2; loginctl terminate-session "$XDG_SESSION_ID" ) >/dev/null 2>&1 &
    '')
  ];
}
