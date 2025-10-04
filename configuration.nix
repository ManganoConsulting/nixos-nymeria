{
  config,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./modules/core/bootloader.nix
    ./modules/core/networking.nix
    ./modules/core/locale.nix
    ./modules/core/users.nix
    ./modules/core/packages.nix
    ./modules/core/programs.nix
    ./modules/core/services.nix
    ./modules/core/security.nix
    ./modules/core/system.nix
    ./modules/core/sound.nix
    ./modules/core/fonts.nix
    ./modules/core/neovim.nix
    ./modules/core/virtualisation.nix
    ./modules/core/hyprland.nix
    ./modules/core/mozillavpn.nix
  ];
}
