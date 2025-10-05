{
  description = "flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Pin nvf to a recent commit that should have better LSP support
    nvf.url = "github:notashelf/nvf";
    nvf.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Secrets management
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nvf, home-manager, sops-nix, ... }: {
    nixosConfigurations.nymeria = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        ./configuration.nix
        nvf.nixosModules.default
        sops-nix.nixosModules.sops
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          # Back up conflicting files instead of failing activation
          home-manager.backupFileExtension = "backup";
          # Make sops-nix options available to Home Manager
          home-manager.sharedModules = [ sops-nix.homeManagerModules.sops ];
          home-manager.users.matthew = import ./home/matthew/home.nix;
        }
      ];
    };
  };
}
