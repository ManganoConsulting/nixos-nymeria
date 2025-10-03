{ config, pkgs, ... }:

{
  system.stateVersion = "25.11";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

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
