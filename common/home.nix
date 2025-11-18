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
    btop
    devenv
    dmidecode
    ffmpeg
    gcc
    imagemagick
    iw
    jq
    lm_sensors
    mprime
    nerd-fonts.jetbrains-mono
    nodejs
    playerctl
    powertop
    ripgrep
    rofi
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
}
