{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    btop
    tree
    fastfetch
    starship
    warp-terminal
    vivaldi
    vivaldi-ffmpeg-codecs
    widevine-cdm
  ];
}
