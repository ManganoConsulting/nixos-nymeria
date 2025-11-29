{
  config,
  pkgs,
  lib,
  ...
}: {
  system.stateVersion = "25.11";
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Default kernel: latest from nixpkgs.
  # Hosts can override this by setting `boot.kernelPackages` in their own config,
  # e.g. in hosts/controlstackos/config.nix:
  #   boot.kernelPackages = pkgs.linuxPackages_lts;
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  # Enable modern graphics stack on 25.05+
  hardware.graphics.enable = true;
  # hardware.graphics.enable32Bit = true; # Uncomment for 32-bit GL (Steam/Wine)

  # Nix store maintenance and optimisation
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  nix.optimise.automatic = true;
  nix.settings.auto-optimise-store = true;
}
