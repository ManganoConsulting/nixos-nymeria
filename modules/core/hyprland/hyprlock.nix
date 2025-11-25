{
  pkgs,
  config,
  ...
}: let
  lockWallpaper = "${../../../assets/controlstackai/lockscreen/lockscreen.png}";
in {
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        no_fade_in = false;
        grace = 0;
        disable_loading_bar = true;
      };

      background = [
        {
          path = lockWallpaper;
          color = "rgba(12, 15, 20, 1.0)";
          blur_passes = 0;
        }
      ];

      input-field = [
        {
          monitor = "";
          size = "200, 50";
          outline_thickness = 3;
          dots_size = 0.33;
          dots_spacing = 0.15;
          dots_center = false;
          dots_rounding = -1;
          outer_color = "rgb(180, 220, 255)"; # Accent
          inner_color = "rgb(12, 15, 20)"; # Ink
          font_color = "rgb(241, 245, 249)"; # Slate 100
          fade_on_empty = true;
          fade_timeout = 1000;
          placeholder_text = "<i>Input Password...</i>";
          hide_input = false;
          rounding = -1;
          check_color = "rgb(36, 42, 54)"; # Grid
          fail_color = "rgb(204, 36, 29)";
          fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
          fail_transition = 300;
          capslock_color = -1;
          numlock_color = -1;
          bothlock_color = -1;
          invert_numlock = false;
          swap_font_color = false;

          position = "0, -20";
          halign = "center";
          valign = "center";
        }
      ];

      label = [
        {
          monitor = "";
          text = "$TIME";
          text_align = "center";
          color = "rgb(241, 245, 249)";
          font_size = 64;
          font_family = "JetBrainsMono Nerd Font";
          rotate = 0;

          position = "0, 80";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
