{pkgs, ...}: {
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      input = {
        "$mod" = "SUPER";
        "$term" = "kitty";
        "$menu" = "rofi -show drun";

        kb_layout = "us,de";
        kb_options = "grp:alt_space_toggle, caps:swapescape";

        follow_mouse = 1;

        sensitivity = 0; # -1.0 - 1.0, 0 means no modification.

        touchpad = {
          natural_scroll = true;
        };
      };
      gestures = {workspace_swipe = true;};

      exec-once = [
        "waybar"
      ];
      monitor = [
        "eDP-1,1920x1080@60.02,auto,1.2"
        "DP-3,1920x1080@144.00,auto,auto"
      ];
      env = [
        "XCURSOR_SIZE,20"
        "HYPRCURSOR_SIZE,20"
        "GDK_SCALE,1.2"
      ];
      xwayland.force_zero_scaling = true;

      bind =
        [
          "$mod, F, exec, zen-beta"
          ", Print, exec, grimblast copy area"
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

          # Scroll through existing workspaces with $mod + scroll
          "$mod, mouse_down, workspace, e+1"
          "$mod, mouse_up, workspace, e-1"
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
        border_size = 2;
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
        "suppressevent maximize, class:."
        "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
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

  programs.waybar = {
    enable = true;
    # You can also define settings here for other Waybar options, like modules, etc.
    settings = {
      mainBar = {
        "layer" = "top";
        "position" = "top"; # Or "bottom", "left", "right"
        "height" = 30; # Adjust as needed
        "spacing" = 4; # Spacing between modules

        # 3. Define modules for the left, center, and right sections
        "modules-left" = ["clock"];
        "modules-center" = ["hyprland/workspaces"]; # Added a clock for a basic working example
        "modules-right" = ["tray" "pulseaudio" "network" "cpu" "memory" "battery"];

        # 4. Minimal configuration for the hyprland/workspaces module
        "hyprland/workspaces" = {
          "format" = "{icon}"; # Shows icons for workspaces (e.g., 1, 2, 3 or custom icons)
          # "format" = "{name}"; # Alternative: shows workspace names if you use named workspaces
          "on-click" = "activate"; # Allows clicking to switch workspaces
          "all-outputs" = true; # Show workspaces from all monitors
          # Optional: Define icons for your workspaces
          # "format-icons" = {
          #   "1" = "";
          #   "2" = "";
          #   "3" = "";
          #   "focused" = "";
          #   "default" = "";
          #   "urgent" = "";
          # };
        };

        # 5. Minimal configuration for the clock module (as an example)
        "clock" = {
          "format" = " {:%H:%M}"; # Example:  14:30
          "tooltip-format" = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };
      };
    };
  };
}
