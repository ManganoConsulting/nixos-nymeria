{ pkgs, config, ... }:
let
  wallpaper = "${../../../assets/controlstackai/wallpapers/wallpaper.png}";
in
{
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
      preload = [ wallpaper ];
      wallpaper = [ ",${wallpaper}" ];
    };
  };
}
