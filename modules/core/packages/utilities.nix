{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    btop
    tree
    fastfetch
    starship
    ghostty
    warp-terminal
    vivaldi
    vivaldi-ffmpeg-codecs
    widevine-cdm

    # Polkit agent (for authentication prompts in Wayland/Hyprland)
    lxqt.lxqt-policykit

    # VPN client
    mozillavpn
  ];
}
