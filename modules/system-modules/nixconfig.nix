{
  config,
  options,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types mkIf optionalString;
  cfg = config.system.nixconfig;
  viewMount = "/run/${cfg.username}/nixos-config";
in {
  imports = lib.optional (inputs ? home-manager) inputs.home-manager.nixosModules.home-manager;

  options.system.nixconfig = {
    enable = mkEnableOption "NixConfig user for secure access";

    username = mkOption {
      type = types.str;
      default = "nixconfig";
      description = "username for the nix admin config user. By default also overrides the group name";
    };

    groupname = mkOption {
      type = types.str;
      default = cfg.username;
      example = "nixuser";
      description = "override the default nix config group";
    };

    configdirectory = mkOption {
      type = types.str;
      default = "/etc/nixos";
    };

    homeManager = {
      enable = mkEnableOption "enable homeManager for nixconfig user";
      stateVersion = mkOption {
        type = types.str;
        default = "24.05";
      };
      extraConfig = mkOption {
        type = types.attrs;
        default = {};
      };
    };
  };

  config = mkIf cfg.enable {
    #creates a custom group for nixconfig
    users.groups.${cfg.groupname} = {};
    # adds the user
    users.users.${cfg.username} = {
      isSystemUser = true;
      group = cfg.username;
      shell = pkgs.zsh;
      createHome = true;
      home = "/var/lib/${cfg.username}";
    };

    security.sudo.extraRules = [
      {
        groups = [cfg.groupname];

        commands = [
          {
            command = "/run/current-system/sw/bin/nixos-rebuild";
            options = ["NOPASSWD"];
          }
          {
            command = "/run/current-system/sw/bin/nix-channel";
            options = ["NOPASSWD"];
          }
          {
            command = "/run/current-system/sw/bin/nix-collect-garbage";
            options = ["NOPASSWD"];
          }
          {
            command = "/run/current-system/sw/bin/nix-env";
            options = ["NOPASSWD"];
          }
        ];
      }
    ];

    # Private mountpoint for the user
    systemd.tmpfiles.rules = [
      "d /run/${cfg.username} 0755 root root -"
      "d ${viewMount} 0755 root root -"
    ];

    # Writable bindfs view: user can create/edit; source stays root-owned.
    fileSystems.${viewMount} = {
      device = cfg.configdirectory;
      fsType = "fuse.bindfs";
      options = [
        # Present everything as owned by the special user/group
        "force-user=${cfg.username}"
        "force-group=${cfg.groupname}"

        # Effective permissions *in the view*
        "perms=0755"
        "create-with-perms=0755"
        "create-as-mounter"

        # Don’t let callers change ownership/mode in the source
        "chown-ignore"
        "chgrp-ignore"
        "chmod-ignore"

        # Required so non-root processes (your user) can access the FUSE mount
        "allow_other"

        # QoL
        "x-systemd.automount"
        "x-systemd.idle-timeout=0"
      ];
      neededForBoot = false;
    };

    home-manager = mkIf cfg.homeManager.enable {
      users.${cfg.username} = {pkgs, ...}: (
        {
          home.username = cfg.username;
          home.homeDirectory = "/var/lib/${cfg.username}";
          home.stateVersion = cfg.homeManager.stateVersion;
          imports = [
            ../hm-modules/shell-config.nix
          ];
          localModules.shellConfig.enable = true;

          programs.zsh.enable = true;
          programs.git.enable = true;
          programs.zoxide.enable = true;
        }
        // cfg.homeManager.extraConfig
      );
    };
  };
}
