{ config, pkgs, lib, ... }:

{
  # Ensure mozillavpn is available system-wide
  environment.systemPackages = [ pkgs.mozillavpn ];

  # Root daemon for Mozilla VPN
  systemd.services.mozillavpn = {
    description = "Mozilla VPN Linux Daemon";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.mozillavpn}/bin/mozillavpn linuxdaemon";
      Restart = "on-failure";
    };
  };
}