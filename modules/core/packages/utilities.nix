{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    btop
    tree
    fastfetch
    starship
    unstable.warp-terminal  # Use latest version from unstable
    vivaldi
    vivaldi-ffmpeg-codecs
    widevine-cdm
  ];
}
