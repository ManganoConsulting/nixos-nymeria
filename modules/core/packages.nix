{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./packages/core.nix
    ./packages/dev-tools.nix
    ./packages/networking.nix
    ./packages/system-tools.nix
    ./packages/utilities.nix
  ];

  nixpkgs.config.allowUnfree = true;
}
