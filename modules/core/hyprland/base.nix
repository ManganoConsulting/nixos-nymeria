{
  config,
  pkgs,
  ...
}: {
  programs.hyprland = {
    enable = true;
  };

  # Hyprland-friendly Wayland environment
  environment.variables = {
    XCURSOR_SIZE = "24";
    HYPRCURSOR_SIZE = "24";
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    EDITOR = "nvim";
    VISUAL = "nvim";
    TERMINAL = "ghostty";

    # Font rendering improvements for Wayland
    QT_QPA_PLATFORM = "wayland";
    GDK_BACKEND = "wayland";
    CLUTTER_BACKEND = "wayland";

    # Better font rendering (adjusted for high DPI display)
    QT_FONT_DPI = "162"; # Actual DPI of your display
    GDK_DPI_SCALE = "1.0";
    QT_AUTO_SCREEN_SCALE_FACTOR = "0";
    QT_SCALE_FACTOR = "1";
    # Additional font rendering variables
    FREETYPE_PROPERTIES = "truetype:interpreter-version=40";
    QT_FONTCONFIG = "1";

    # Force some apps to use Wayland (when possible)
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
  };

  # XDG portals for screen share / file pickers under Hyprland
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [
    pkgs.xdg-desktop-portal-hyprland
    pkgs.xdg-desktop-portal-gtk
  ];
  # Ensure FileChooser and others are provided by GTK backend while using Hyprland
  xdg.portal.config = {
    common = {
      default = ["hyprland" "gtk"];
    };
  };
  xdg.portal.xdgOpenUsePortal = true;
}
