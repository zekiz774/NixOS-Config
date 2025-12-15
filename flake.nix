{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      # reuse the same nixpkgs to stay fast & consistent
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    preload-ng = {
      url = "github:miguel-b-p/preload-ng";
      inputs.preload-ngurl.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nur,
    hyprland,
    ...
  } @ inputs: let
    system = "x86_64-linux";

    # Create a consistent pkgs set with all overlays applied
    pkgs = import nixpkgs {
      inherit system;
      overlays = [
        nur.overlays.default
        hyprland.overlays.default
      ];
      config.allowUnfree = true;
    };
  in {
    # system configuration
    nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
      inherit system;
      pkgs = pkgs;
      specialArgs = {inherit inputs;};
      modules = [
        ./hosts/desktop/configuration.nix
      ];
    };

    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
      inherit system;
      pkgs = pkgs;
      specialArgs = {inherit inputs;};
      modules = [
        ./hosts/laptop/configuration.nix
      ];
    };

    # home configuration
    homeConfigurations.desktop = home-manager.lib.homeManagerConfiguration {
      pkgs = pkgs;

      extraSpecialArgs = {inherit inputs;};
      modules = [
        ./hosts/desktop/home.nix
      ];
    };

    homeConfigurations.laptop = home-manager.lib.homeManagerConfiguration {
      pkgs = pkgs;

      extraSpecialArgs = {inherit inputs;};
      modules = [
        ./hosts/laptop/home.nix
      ];
    };
  };
}
