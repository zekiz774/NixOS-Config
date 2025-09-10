{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types mkIf optionalString;
  cfg = config.system.nixconfig;
  viewMount = "/run/${cfg.username}/nixos-config";
in {
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
  };

  config = mkIf cfg.enable {
    #creates a custom group for nixconfig
    users.groups.${cfg.username} = {};
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
      "d ${viewMount} 0700 root root -"
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
        "perms=0700" # only that user can R/W/X in the view
        "create-with-perms=0700" # default perms for new files (tweak as you like)

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
  };
}
