{
  pkgs,
  inputs,
  system,
  ...
}: {
  imports = [
    ../modules/hm-modules/asfp-overlay.nix
  ];
  home.packages = with pkgs; [
    #desktop
    appimage-run
    chromium
    gimp
    godot
    lutris
    obsidian
    rofi
    tor-browser
    vesktop

    # tools
    arrpc
    bc
    btop
    bun
    devenv
    dmidecode
    ffmpeg
    gcc
    imagemagick
    iw
    jq
    libva-utils
    lm_sensors
    mprime
    nerd-fonts.jetbrains-mono
    nodejs
    playerctl
    powertop
    ripgrep
    rofi
    socat
    steam-run
    tree
    unzip
    usbutils
    vulkan-tools
    wev
    wine
    winetricks
    yt-dlp
  ];

  programs.kitty = {
    enable = true;
    settings = {
      confirm_os_window_close = 0;

      accent = "#fcf458";
      warning = "#fc5876";
      background = "#1b1d1e";
      foreground = "#c5c5be";

      color1 = "#fc5876";
      color6 = "#a2a2a5";
      color14 = "#615f5e";
    };
    themeFile = "Batman";
  };

  programs.vesktop.enable = true;
}
