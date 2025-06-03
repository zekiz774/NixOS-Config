{pkgs, ...}: {
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      input = {
        "$mod" = "SUPER";
        "$term" = "kitty";
        "$menu" = "rofi --show drun";

        kb_layout = "us,de";
        kb_options = "grp:alt_space_toggle";

        follow_mouse = 1;

        sensitivity = 0; # -1.0 - 1.0, 0 means no modification.

        touchpad = {
          natural_scroll = true;
        };
      };
      gestures = {
        workspace_swipe = false;
      };

      exec-once = [
        "waybar"
      ];
      monitor = ["eDP-1,1920x1080@60.02,auto,1.2" "DP-3,1920x1080@144.00,auto,auto"];
      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,23"
      ];

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
      #look and feel
      general = {
        gaps_in = 5;
        gaps_out = 20;
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
          passes = 1;

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
    size = 16;
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
  programs.waybar.enable = true;
}
