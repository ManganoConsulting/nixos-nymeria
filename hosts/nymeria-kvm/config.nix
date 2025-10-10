{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../modules/core/networking.nix
    ../../modules/core/bootloader.nix
    ../../modules/core/mozillavpn.nix
    ../../modules/core/cloudflare-warp.nix
    ../../modules/core/vpn-killswitch.nix
  ];

  networking.hostName = lib.mkForce "nymeria-kvm";
}
