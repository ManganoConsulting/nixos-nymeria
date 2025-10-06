{
  config,
  pkgs,
  ...
}: {
  wayland.windowManager.hyprland.settings.exec-once = [
    # Start a Polkit authentication agent so privilege prompts work
    "lxqt-policykit-agent"
    # Start Sway Notification Center (notification daemon + panel)
    "swaync"

    # Uncomment these if needed
    # "$terminal"
    # "nm-applet &"
    # "waybar & hyprpaper & vivaldi"
  ];
}
