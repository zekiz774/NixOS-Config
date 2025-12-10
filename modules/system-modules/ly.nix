{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkOption type mkIf;
  cfg = config.localModules.ly;

  tuigreet = "${pkgs.tuigreet}/bin/tuigreet";
  sessions = "${config.services.displayManager.sessionData.desktops}/share/xsessions:${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
in {
  options.localModules.ly = {
    enable = mkEnableOption "Enable custom Ly config";
  };
  config = mkIf cfg.enable {
    #nixpkgs.overlays = [
    #  (final: prev: {
    #    ly = prev.ly.overrideAttrs (old: {
    #      src = final.fetchgit {
    #        url = "https://codeberg.org/fairyglade/ly.git";
    #        rev = "1537addd6787720f5afc0e793a5b21102c022756";
    #        sha256 = "sha256-x5Mz0ZsDHtsTXwVqzDoFadtdhRafRYxB1zMGppsd+ps=";
    #      };
    #    });
    #  })
    #];

    # services.displayManager.ly = {
    #   enable = true;
    #   settings = {
    #     animate = true;
    #     animation = "colormix";

    #     #auto_login_session = "hyprland";
    #     #auto_login_user = "zekiz";
    #   };
    # };

    services.greetd = {
      enable = true;
      settings = rec {
        initial_session = {
          command = "${pkgs.hyprland}/bin/start-hyprland";
          user = "zekiz";
        };
        default_session = {
          command = "${tuigreet} --time --remember --remember-session --sessions ${sessions}";
          user = "greeter";
        };
      };
    };

    services.displayManager.autoLogin.enable = true;
    services.displayManager.autoLogin.user = "zekiz";
  };
}
