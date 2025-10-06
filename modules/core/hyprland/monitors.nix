{
  config,
  pkgs,
  ...
}: {
  wayland.windowManager.hyprland.settings = {
    monitor = [
      # High DPI laptop display - explicit configuration for better font rendering
      "eDP-1, 1920x1080@60, 0x0, 1"
      # Fallback for other monitors
      ", preferred, auto, auto"
    ];

    # High DPI specific settings
    misc = {
      # Better font rendering on high DPI
      force_default_wallpaper = 0;
    };

    # XWayland scaling for better app compatibility
    xwayland = {
      force_zero_scaling = true;
    };
  };
}
