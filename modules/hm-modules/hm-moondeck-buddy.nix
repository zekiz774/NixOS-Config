{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types mkIf optionalString;
  cfg = config.programs.moondeck-buddy;
  urlFromVersion = v: "https://github.com/FrogTheFrog/moondeck-buddy/releases/download/v${v}/MoonDeckBuddy-${v}-x86_64.AppImage";

  pkg = pkgs.appimageTools.wrapType2 {
    pname = "moondeck-buddy";
    version = cfg.version;
    src = pkgs.fetchurl {
      url = urlFromVersion cfg.version;
      sha256 = cfg.sha256;
    };
  };
in {
  options.programs.moondeck-buddy = {
    enable = mkEnableOption "MoonDeckBuddy (Home Manager)";

    autostart = mkOption {
      type = types.bool;
      default = false;
      description = "Start MoonDeckBuddy automatically on login.";
    };

    version = mkOption {
      type = types.str;
      default = "1.9.0";
      description = "MoonDeckBuddy upstream realse version.";
    };

    sha256 = mkOption {
      type = types.str;
      default = "sha256-WViuJPiJ/7ej6mpTMJD1MfszAkAQmrrIBKGtVMe9Qik=";
      description = "Override the download sha256.";
    };

    extraArgs = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Extra CLI args passed to the binary.";
    };

    package = mkOption {
      type = types.package;
      default = pkg;
      readOnly = true;
      description = "The wrapped AppImage package.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];

    xdg.desktopEntries.moondeck-buddy = {
      name = "MoonDeckBuddy";
      exec = "moondeck-buddy ${optionalString (cfg.extraArgs != []) (lib.concatStringsSep " " cfg.extraArgs)}";
      categories = ["Game" "Utility"];
      terminal = false;
    };

    systemd.user.services.moondeck-buddy = mkIf cfg.autostart {
      Unit = {
        Description = "MoonDeckBuddy";
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
      };
      Service = {
        ExecStart = "${cfg.package}/bin/moondeck-buddy ${lib.concatStringsSep " " cfg.extraArgs}";
        Restart = "on-failure";
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };
}
