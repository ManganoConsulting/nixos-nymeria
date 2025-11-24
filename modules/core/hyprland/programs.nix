{
  config,
  pkgs,
  ...
}: {
  wayland.windowManager.hyprland.settings = {
    "$terminal" = "ghostty";
    "$fileManager" = "dolphin";
    "$menu" = "wofi --show drun";
    "$browser" = "vivaldi";
  };
  # Place scripts in ~/.config/hypr/scripts
  home.file.".config/hypr/scripts/status_overlay.sh" = {
    source = ./scripts/status_overlay.sh;
    executable = true;
  };
  home.file.".config/hypr/scripts/cheatsheet_overlay.sh" = {
    source = ./scripts/cheatsheet_overlay.sh;
    executable = true;
  };
  home.file.".config/hypr/scripts/cheatsheet.txt".source = ./scripts/cheatsheet.txt;
}
