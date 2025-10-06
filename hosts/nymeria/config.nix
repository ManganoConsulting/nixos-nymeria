{
  config,
  pkgs,
  lib,
  ...
}: {
  # Host-specific toggles and imports
  imports = [
    ../../modules/core/networking.nix
    ../../modules/core/bootloader.nix
    ../../modules/core/mozillavpn.nix
    ../../modules/core/cloudflare-warp.nix
    ../../modules/core/vpn-killswitch.nix
  ];

  # Example: enable runtime toggle script for VPN kill switch (declarative kill switch remains disabled by default)
  # my.vpnKillSwitch.enable = false;

  # Example secret mapping guarded by file existence (non-breaking placeholder)
  sops.secrets."example-password" = lib.mkIf (builtins.pathExists ../../secrets/example.yaml) {
    sopsFile = ../../secrets/example.yaml;
  };
  # Usage example:
  # services.postgresql = {
  #   enable = true;
  #   # passwordFile will be provided by sops-nix at build time
  #   authentication = {
  #     passwordFile = config.sops.secrets."example-password".path;
  #   };
  # };
}
