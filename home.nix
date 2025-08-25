{
  config,
  pkgs,
  inputs,
  system,
  ...
}: {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "zekiz";
  home.homeDirectory = "/home/zekiz";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.

  imports = [
    inputs.zen-browser.homeModules.beta
    inputs.nvf.homeManagerModules.default

    ./hyprland.nix
    ./modules/hm-moondeck-buddy.nix
  ];

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    wl-clipboard
    nerd-fonts.jetbrains-mono
    onlyoffice-bin
    vesktop
    obsidian
    grc
    gcc
    ripgrep
    nodejs
    imagemagick
    ffmpeg
    yt-dlp
    godot
    rofi-wayland
    btop
    powertop
    playerctl
    brightnessctl
    usbutils
    steam-run
    prismlauncher

    #hardware utils
    iw
    lm_sensors
    radeontop
    corectrl
    mprime
    vulkan-tools

    #desktop
    open-webui
    blender-hip

    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/zekiz/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    NIXOS_OZONE_WL = 1;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        theme = {
          enable = true;
          name = "tokyonight";
          transparent = true;
          style = "night";
        };
        telescope.enable = true;
        autocomplete.nvim-cmp.enable = true;
        viAlias = true;
        vimAlias = true;
        lsp = {
          enable = true;
          formatOnSave = true;
        };
        clipboard = {
          enable = true;
          providers.wl-copy.enable = true;
          registers = "unnamedplus";
        };

        languages = {
          enableTreesitter = true;
          enableFormat = true;
          enableExtraDiagnostics = true;

          nix = {
            enable = true;
          };
          css.enable = true;
          ts.enable = true;
          markdown.enable = true;
        };
        options = {
          shiftwidth = 4;
          tabstop = 4;
        };

        formatter.conform-nvim.enable = true;
        utility.snacks-nvim.enable = true;
        binds.whichKey.enable = true;
        utility.oil-nvim.enable = true;
        globals.editorconfig = true;
      };
    };
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
    '';
    plugins = [
      {
        name = "grc";
        src = pkgs.fishPlugins.grc.src;
      }
      {
        name = "git";
        src = pkgs.fishPlugins.plugin-git.src;
      }
    ];
  };
  programs.zoxide.enable = true;

  programs.zen-browser = {
    enable = true;
    nativeMessagingHosts = [pkgs.firefoxpwa];

    policies = {
      AutofillAddressEnabled = true;
      AutofillCreditCardEnabled = false;
      DisableAppUpdate = true;
      DisableFeedbackCommands = true;
      DisableFirefoxStudies = true;
      DisablePocket = true; # save webs for later reading
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      NoDefaultBookmarks = true;
      OfferToSaveLogins = false;
    };
    profiles.default = {
      extensions = {
        packages = with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
          bitwarden
          sponsorblock
        ];
        settings."uBlock0@raymondhill.net".settings = {
          selectedFilterLists = [
            "ublock-filters"
            "ublock-badware"
            "ublock-privacy"
            "ublock-unbreak"
            "ublock-quick-fixes"
          ];
          userFilters = ''
            ||reddit.com^$removeparam=tl
          '';
        };
        force = true;
      };
      settings = {
        "extensions.autoDisableScopes" = 0;
        "browser.startup.page" = 0; # 0 = blank page, 1 = homepage, 3 = restore previous session
        "browser.sessionstore.resume_from_crash" = false;
        "browser.sessionstore.resume_session_once" = false;
        "browser.tabs.allow_transparent_browser" = true;
        "zen.widget.linux.transparency" = true;
        "zen.view.compact.hide-toolbar" = true;
      };
    };
  };

  programs.git = {
    enable = true;
    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
  };
  programs.kitty = {
    enable = true;
    settings = {
      background_opacity = 0.5;
      confirm_os_window_close = 0;
    };
  };
  programs.starship = {
    enable = true;
  };
  programs.bash = {
    enable = true;
    bashrcExtra = ''
      if [[ $(ps --no-header --pid=$PPID --format=comm) != "fish" && -z "$BASH_EXECUTION_STRING" ]]; then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec fish $LOGIN_OPTION
      fi
    '';
  };

  programs.moondeck-buddy = {
    enable = true;
    autostart = true;
    version = "1.9.0";
  };
}
