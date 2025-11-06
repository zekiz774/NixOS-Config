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
    ../../modules/hm-modules/hm-hyprland.nix
    ../../modules/hm-modules/hm-moondeck-buddy.nix
    ../../modules/hm-modules/shell-config.nix
    ../../modules/hm-modules/editor-config.nix
    ../../common/home.nix
  ];

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    blender-hip
    kdePackages.kdenlive
    nexusmods-app-unfree
    orca-slicer
    osu-lazer-bin
    prismlauncher

    # Tools
    radeontop
    vulkan-tools

    (python313.withPackages (ps: [
      (ps.torch.override {rocmSupport = true;})
    ]))
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

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

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
        "browser.tabs.allow_transparent_browser" = false;
        "zen.widget.linux.transparency" = false;
        "zen.view.compact.hide-toolbar" = true;
      };
    };
  };

  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      safe.directory = "/etc/nixos";
    };
  };

  programs.kitty = {
    enable = true;
    settings = {
      background_opacity = 0.5;
      confirm_os_window_close = 0;
    };
  };

  programs.moondeck-buddy = {
    enable = true;
    autostart = true;
    version = "1.9.0";
  };

  localModules.hyprland = {
    enable = true;
    monitors = [
      "DP-3,1920x1080@144, auto, 1"
      "HDMI-A-1, 3840x2160@120.00Hz, auto, 1.5"
    ];
  };
  localModules.shellConfig.enable = true;
  localModules.editorConfig.enable = true;

  programs.obs-studio = {
    enable = true;

    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
      obs-vaapi #optional AMD hardware acceleration
      obs-gstreamer
      obs-vkcapture
    ];
  };
}
