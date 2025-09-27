{ config, pkgs, ... }:

{
  networking.hostName = "nymeria";
  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;
}

