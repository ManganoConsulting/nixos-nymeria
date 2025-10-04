{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland.settings.exec-once = [
    # Start a Polkit authentication agent so privilege prompts work
    "lxqt-policykit-agent"

    # Uncomment these if needed
    # "$terminal"
    # "nm-applet &"
    # "waybar & hyprpaper & vivaldi"
  ];
}
