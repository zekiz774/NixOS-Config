{
  pkgs,
  lib,
  ...
}: {
  nixpkgs.overlays = [
    (final: prev: {
      androidStudioForPlatformPackages.canary = prev.androidStudioForPlatformPackages.canary.overrideAttrs (old: {
        name = "asfp-canary-narwhal-4-feature-drop-2025.1.4.4-linux.deb";
        src = prev.fetchurl {
          url = "https://dl.google.com/android/asfp/asfp-canary-Narwhal%204%20Feature%20Drop-2025.1.4.4-linux.deb";
          sha256 = "sha256-Ip860cUTU2Bt3G8D2QfqFTMDchJD/zJ+Q7kdU45N81g=";
          name = "asfp-canary-narwhal-4-feature-drop-2025.1.4.4-linux.deb";
        };
      });
    })
  ];
}
