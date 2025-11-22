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

    # Optional hardware profiles and declarative partitioning
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # Dev hygiene: pre-commit hooks
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    nvf,
    home-manager,
    sops-nix,
    nixos-hardware,
    disko,
    pre-commit-hooks,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
  in {
    nixosConfigurations = {
      nymeria = nixpkgs.lib.nixosSystem {
        system = system;

        modules = [
          ./hosts/nymeria/hardware-configuration.nix
          ./modules/common.nix
          ./modules/desktop.nix
          ./hosts/nymeria/config.nix

          # Optional imports (uncomment and adjust as needed):
          # nixos-hardware.nixosModules.lenovo-thinkpad-x1-9th-gen

          disko.nixosModules.disko
          ./modules/disko/baremetal-zfs-encrypted.nix

          # Existing modules preserved
          nvf.nixosModules.default
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # Back up conflicting files instead of failing activation
            home-manager.backupFileExtension = "backup";
            # Make sops-nix options available to Home Manager
            home-manager.sharedModules = [sops-nix.homeManagerModules.sops];
            home-manager.users.matthew = import ./home/matthew.nix;
          }
          ({config, ...}: {
            boot.supportedFilesystems = ["zfs"];
            networking.hostId = builtins.substring 0 8 (builtins.hashString "sha256" config.networking.hostName);
            boot.zfs.devNodes = "/dev/disk/by-id";
            services.zfs.autoScrub.enable = true;
            services.zfs.trim.enable = true;
            zramSwap.enable = true;
          })
        ];
      };

      nymeria-vmware = nixpkgs.lib.nixosSystem {
        system = system;

        modules = [
          ./hosts/nymeria-vmware/hardware-configuration.nix
          ./modules/common.nix
          ./modules/desktop.nix
          ./hosts/nymeria-vmware/config.nix

          disko.nixosModules.disko
          ./modules/disko/vmware-zfs.nix
          ./modules/vmware-guest.nix

          nvf.nixosModules.default
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.sharedModules = [sops-nix.homeManagerModules.sops];
            home-manager.users.matthew = import ./home/matthew.nix;
          }
          ({config, ...}: {
            boot.supportedFilesystems = ["zfs"];
            networking.hostId = builtins.substring 0 8 (builtins.hashString "sha256" config.networking.hostName);
            boot.zfs.devNodes = "/dev/disk/by-id";
            services.zfs.autoScrub.enable = true;
            services.zfs.trim.enable = true;
            zramSwap.enable = true;
          })
        ];
      };

      nymeria-kvm = nixpkgs.lib.nixosSystem {
        system = system;

        modules = [
          ./hosts/nymeria-kvm/hardware-configuration.nix
          ./modules/common.nix
          ./modules/desktop.nix
          ./hosts/nymeria-kvm/config.nix

          disko.nixosModules.disko
          ./modules/disko/kvm-zfs.nix
          ./modules/qemu-guest.nix

          nvf.nixosModules.default
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.sharedModules = [sops-nix.homeManagerModules.sops];
            home-manager.users.matthew = import ./home/matthew.nix;
          }
          ({config, ...}: {
            boot.supportedFilesystems = ["zfs"];
            networking.hostId = builtins.substring 0 8 (builtins.hashString "sha256" config.networking.hostName);
            boot.zfs.devNodes = "/dev/disk/by-id";
            services.zfs.autoScrub.enable = true;
            services.zfs.trim.enable = true;
            zramSwap.enable = true;
          })
        ];
      };

      # Minimal VM configuration for smoke tests
      vm = nixpkgs.lib.nixosSystem {
        system = system;
        modules = [
          nvf.nixosModules.default
          ./modules/common.nix
          ./modules/vm-guest.nix
          {
            networking.hostName = "vm";
            # A minimal root filesystem to satisfy NixOS assertions for VM builds
            fileSystems."/" = {
              device = "nodev";
              fsType = "tmpfs";
              options = ["mode=0755"];
            };
            # No bootloader needed for qemu-vm builder
            boot.loader.grub.enable = false;
            boot.loader.systemd-boot.enable = false;
          }
        ];
      };
    };

    # per-system outputs
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        git
        sops
        age
        just
        statix
        deadnix
        alejandra
        nil
        nix-output-monitor
        pre-commit
      ];
      shellHook = ''
        pre-commit install --install-hooks || true
        echo "Dev shell ready: nix fmt, statix, deadnix, pre-commit hooks installed."
      '';
    };

    formatter.${system} = pkgs.alejandra;

    # Checks: lint, pre-commit, and host builds
    checks.${system} = {
      default = pkgs.stdenv.mkDerivation {
        name = "lint";
        src = ./.;
        buildCommand = ''
          ${pkgs.statix}/bin/statix check .
          ${pkgs.deadnix}/bin/deadnix --fail .
          mkdir -p $out
        '';
      };

      nymeria = self.nixosConfigurations.nymeria.config.system.build.toplevel;
      nymeria-vmware = self.nixosConfigurations.nymeria-vmware.config.system.build.toplevel;
      nymeria-kvm = self.nixosConfigurations.nymeria-kvm.config.system.build.toplevel;
      vm = self.nixosConfigurations.vm.config.system.build.vm;
    };

    # Optional: Nix-native pre-commit runner (invoked via nix build)
    packages.${system}.pre-commit-check = pre-commit-hooks.lib.${system}.run {
      src = ./.;
      hooks = {
        alejandra.enable = true;
        statix.enable = true;
        deadnix.enable = true;
        shellcheck.enable = true;
        shfmt.enable = true;
        markdownlint.enable = true;
      };
    };
  };
}
