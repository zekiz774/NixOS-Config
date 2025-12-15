{
  pkgs,
  inputs,
  system,
  ...
}: {
  imports = [
    inputs.preload-ng.nixosModules.default
  ];

  services.preload-ng.enable = true;
  services.preload-ng = {
    settings = {
      # Faster cycles for NVMe responsiveness
      cycle = 15;

      # Memory tuning for 16GB RAM
      memTotal = -5;
      memFree = 70;
      memCached = 10;
      memBuffers = 50;

      # Track smaller files (1MB min)
      minSize = 1000000;

      # More parallelism (Ryzen 5600G)
      processes = 60;

      # No sorting needed for NVMe (no seek penalty)
      sortStrategy = 0;

      # Save state every 30 min
      autoSave = 1800;

      # NixOS-specific paths (Already implemented on preload-ng flake)
      mapPrefix = "/nix/store/;/run/current-system/;!/";
      exePrefix = "/nix/store/;/run/current-system/;!/";
    };
  };
}
