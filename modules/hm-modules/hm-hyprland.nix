{
  pkgs,
  options,
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types mkIf;
  cfg = config.localModules.hyprland;
in {
  options.localModules.hyprland = {
    enable = mkEnableOption "My hyprland configuration";
    monitors = mkOption {
      type = types.listOf types.str;
      default = [];
      example =
        "eDP-1,1920x1080@60.02,auto,1.2"
        "DP-3,1920x1080@144.00,auto,auto";
      description = "the monitor config passed to hyprland";
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      pavucontrol
      wl-clipboard
      grim
      slurp
      libnotify
      jq

      (writeShellScriptBin "screenshot" ''
        #!/usr/bin/env sh

        shutter="${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/camera-shutter.oga"
        file="$HOME/Pictures/screenshots/screenshot-$(date +'%Y%m%d-%H%M%S').png"

        if [ "$1" = "--region" ]; then

                selection=$(slurp)
                if [ $? -ne 0 ] || [ -z "$selection" ]; then
                    notify-send "Screenshot cancelled"
                    exit 1
                fi

                pw-play "$shutter"
                grim -c -g "$selection" "$file"
        else
                active_output=$(hyprctl -j activeworkspace | jq -r '.monitor')

                pw-play $shutter
                grim -c -o $active_output "$file"
        fi

                wl-copy < "$file"
        notify-send "Screenshot saved" "$file"
      '')
    ];

    # set a notification deamon
    services.swaync.enable = true;

    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        input = {
          "$mod" = "SUPER";
          "$term" = "kitty";
          "$menu" = "rofi -show drun";

          kb_layout = "us,de";
          kb_options = "grp:alt_space_toggle, caps:escape";

          follow_mouse = 1;

          sensitivity = 0; # -1.0 - 1.0, 0 means no modification.

          touchpad = {
            natural_scroll = true;
          };
        };

        exec-once = [
          "waybar"
        ];

        monitor = cfg.monitors;
        render = {
          cm_fs_passthrough = 2;
          cm_auto_hdr = 1;
        };
        experimental = {
          xx_color_management_v4 = true;
        };

        env = [
          "XCURSOR_SIZE,20"
          "HYPRCURSOR_SIZE,20"
          "GDK_SCALE,1.2"
        ];

        xwayland.force_zero_scaling = true;
        debug.full_cm_proto = true;

        bind =
          [
            "$mod, B, exec, zen-beta"
            # screenshot
            '', Print, exec, screenshot --region''

            ''$mod SHIFT, S, exec, screenshot --region''

            ''$mod, S, exec, screenshot ''

            "$mod, SPACE, exec, $menu"
            "$mod, return, exec, kitty"
            "$mod, M, exit"
            "$mod, Q, killactive"

            "$mod, P, pseudo, "
            "$mod, S, togglesplit, "
            # Move focus with mod + arrow keys
            "$mod, h, movefocus, l"
            "$mod, l, movefocus, r"
            "$mod, k, movefocus, u"
            "$mod, j, movefocus, d"
          ]
          ++ (
            # workspaces
            # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
            builtins.concatLists (builtins.genList (
                i: let
                  ws = i + 1;
                in [
                  "$mod, code:1${toString i}, workspace, ${toString ws}"
                  "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
                ]
              )
              9)
          );

        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, rezizewindow"
        ];
        bindel = [
          ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
          ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
          ",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
          ",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
        ];
        bindl = [
          ",XF86AudioNext, exec, playerctl next"
          ",XF86AudioPause, exec, playerctl play-pause"
          ",XF86AudioPlay, exec, playerctl play-pause"
          ",XF86AudioPrev, exec, playerctl previous"
        ];
        #look and feel
        general = {
          gaps_in = 5;
          gaps_out = 10;
          border_size = 1;
          allow_tearing = false;

          layout = "dwindle";
        };

        decoration = {
          rounding = 10;
          rounding_power = 2;

          # Change transparency of focused and unfocused windows
          active_opacity = 1.0;
          inactive_opacity = 1.0;

          shadow = {
            enabled = true;
            range = 4;
            render_power = 3;
            color = "rgba(1a1a1aee)";
          };

          # https://wiki.hyprland.org/Configuring/Variables/#blur
          blur = {
            enabled = true;
            size = 3;
            passes = 2;
            vibrancy = 0.1796;
          };
        };

        windowrule = [
          " match:class .*,suppress_event maximize"
          " match:class ^$,match:title ^$, match:xwayland 1, match:float 1, match:fullscreen_state_internal 2, match:pin 0, no_initial_focus on"
          "fullscreen on, match:class ^(steam_app|heroic|lutris|bottles).*"
        ];
      };
    };

    home.pointerCursor = {
      gtk.enable = true;
      # x11.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 20;
    };

    gtk = {
      enable = true;

      theme = {
        package = pkgs.flat-remix-gtk;
        name = "Flat-Remix-GTK-Grey-Darkest";
      };

      iconTheme = {
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
      };

      font = {
        name = "Sans";
        size = 11;
      };
    };
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [xdg-desktop-portal-gtk xdg-desktop-portal-hyprland];
      config = {
        hyprland = {
          default = ["hyprland" "gtk"];
          "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
        };
      };
    };

    programs.waybar = {
      enable = true;
      settings = {
        mainBar = {
          "layer" = "top";
          "position" = "bottom";
          "height" = 40;
          "spacing" = 4;

          # 3. Define modules for the left, center, and right sections
          "modules-center" = ["clock"];
          "modules-left" = ["hyprland/workspaces"]; # Added a clock for a basic working example
          "modules-right" = ["tray" "pulseaudio" "network" "cpu" "memory" "battery"];

          # 4. Minimal configuration for the hyprland/workspaces module
          "hyprland/workspaces" = {
            "format" = "{icon}"; # Shows icons for workspaces (e.g., 1, 2, 3 or custom icons)
            # "format" = "{name}"; # Alternative: shows workspace names if you use named workspaces
            "on-click" = "activate"; # Allows clicking to switch workspaces
            "all-outputs" = true; # Show workspaces from all monitors
          };

          # 5. Minimal configuration for the clock module (as an example)
          "clock" = {
            "format" = " {:%H:%M}"; # Example:  14:30
          };

          "network" = {
            "format" = "{essid} {signal}%";
            "format-alt" = "{ifname} {ipaddr}/{cidr}";

            "format-icons" = {
              "wifi" = ["󰤨" "󰤥" "󰤢" "󰤟" "󰤯"];
              "ethernet" = ["󰈁"];
              "disconnected" = ["󰤭"];
            };
          };
        };
      };
    };
    home.file.".config/waybar/style.css".source = ../../configs/waybar.css;
  };
}
