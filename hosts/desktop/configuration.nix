# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  inputs,
  ...
}: let
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules/system-modules/gamescope.nix
    ../../modules/system-modules/nixconfig.nix
    ../../modules/system-modules/ly.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot = {
    enable = false;
    configurationLimit = 10;
  };

  boot.loader.grub = {
    enable = true;

    device = "nodev";
    useOSProber = true;
    efiSupport = true;
  };

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # displayManager config
  localModules.ly.enable = true;
  # Enable the GNOME Desktop Environment.

  services.desktopManager.gnome.enable = true;
  environment.gnome.excludePackages = with pkgs; [orca];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us,de";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "us";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.zekiz = {
    isNormalUser = true;
    description = "zekiz";
    extraGroups = ["networkmanager" "wheel" "corectrl"];
    packages = with pkgs; [
      #  thunderbird
    ];
  };

  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;
  programs.tmux = {
    enable = true;
  };

  # Install firefox.
  programs.firefox.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; import ./packages.nix {inherit pkgs;};

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "both";
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # hyprland configuration
  # sets up cachix mirror for hyprland
  nix.settings = {
    substituters = [
      "https://hyprland.cachix.org"
      "https://aseipp-nix-cache.global.ssl.fastly.net"
      "https://devenv.cachix.org"
    ];
    trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    ];
    http-connections = 128;
    max-substitution-jobs = 128;
    max-jobs = "auto";
  };

  programs.hyprland = {
    enable = true;
    # set the flake package
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    # make sure to also set the portal package, so that they are in sync
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    xwayland.enable = true;
  };

  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
      gtkUsePortal = true;
    };
  };

  services.hardware.openrgb.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    protontricks.enable = true;
    gamescopeSession = {
      enable = true;
      args = [
        "-W 3849"
        "-H 2160"
        "--backend drm"
        "--adaptive-sync"
        "-O HDMI-A-1"

        "--rt"
        "--hdr-enabled"
        "--mangoapp"
      ];
      env = {
        "LIBSEAT_BACKEND" = "logind";
      };
      steamArgs = [
        "-tenfoot"
        "-pipewire-dmabuf"
      ];
    };
  };

  programs.gamemode.enable = true;
  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [rocmPackages.clr.icd rocmPackages.hiprt];
  };

  programs.alvr = {
    enable = false;
    openFirewall = true;
  };

  systemd.tmpfiles.rules = let
    rocmEnv = pkgs.symlinkJoin {
      name = "rocm-combined";
      paths = with pkgs.rocmPackages; [
        rocblas
        hipblas
        clr
        hiprt
      ];
    };
  in [
    "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
  ];

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };

  services.udev.extraRules = ''
    # 8BitDo Ultimate 2 Dongle
    KERNEL=="hidraw*", ATTRS{idVendor}=="2dc8", ATTRS{idProduct}=="6012", MODE="066"

    # 8BitDo Ultimate 2 BT
    KERNEL=="hidraw*", KERNELS=="*2DC8:6012*", MODE="0660", TAG+="uaccess"
  '';

  services.udev.packages = [pkgs.via];
  hardware.keyboard.qmk.enable = true;

  services.ollama = {
    enable = true;
    acceleration = "rocm";
  };
  services.open-webui = {
    enable = false;
    openFirewall = true;
    environment = {
      ANONYMIZED_TELEMETRY = "False";
      DO_NOT_TRACK = "True";
      SCARF_NO_ANALYTICS = "True";
      WEBUI_AUTH = "True";

      ENABLE_RAG_WEB_SEARCH = "True";
      SEARXNG_HOSTNAME = "localhost:8089";
      SEARXNG_UWSGI_WORKERS = "8";
      SEARXNG_UWSGI_THREADS = "8";
      RAG_WEB_SEARCH_ENGINE = "searxng";
      RAG_WEB_SEARCH_RESULT_COUNT = "3";
      RAG_WEB_SEARCH_CONCURRENT_REQUESTS = "10";
      SEARXNG_QUERY_URL = "http://127.0.0.1:8089/search?q=<query>";
    };
  };

  services.searx = {
    enable = true;
    redisCreateLocally = true;
    settings.server.secret_key = "test";
    settings.server.port = 8089;
    settings.server.bind_address = "0.0.0.0";
    settings.search.formats = ["html" "json" "rss"];
  };

  system.nixconfig = {
    enable = true;
    homeManager.enable = true;
  };

  services.printing.drivers = [
    pkgs.brlaser
    pkgs.brgenml1lpr
    pkgs.brgenml1cupswrapper
  ];

  hardware.opentabletdriver = {
    enable = true;
    daemon.enable = true;
    blacklistedKernelModules = ["wacom"];
  };

  programs.corectrl.enable = true;

  # Disable the AT-SPI bus for all users
  systemd.user.services.at-spi-dbus-bus.enable = false;
}
