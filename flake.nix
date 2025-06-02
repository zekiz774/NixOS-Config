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
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nvf,
    zen-browser,
    nur,
    ...
  } @ inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      modules = [
        # your regular system config
        {
          nixpkgs.overlays = [nur.overlays.default];
        }
        ./configuration.nix
        # bring Home-Manager in as a NixOS module
        home-manager.nixosModules.home-manager

        # —–––––––– Home-Manager settings ––––––––
        {
          # use the same pkgs for system + user
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "HMBackup";

          home-manager.users.zekiz = {
            imports = [
              ./home.nix
            ];
          };

          home-manager.extraSpecialArgs = {
            inherit inputs; # lets you use `inputs.nvf` etc. in home.nix
            system = "x86_64-linux"; # often handy to have
          };
        }
      ];
    };
  };
}
