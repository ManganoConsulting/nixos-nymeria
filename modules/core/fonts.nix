{pkgs, ...}: {
  fonts = {
    packages = with pkgs; [
      # Emoji and international fonts
      noto-fonts-color-emoji
      noto-fonts-cjk-sans

      # Icon fonts
      font-awesome
      symbola
      material-icons

      # High-quality terminal fonts
      fira-code
      fira-code-symbols
      nerd-fonts.fira-code # Nerd Font version with icons
      nerd-fonts.jetbrains-mono
      nerd-fonts.hack
      hack-font # Warp's default font
      jetbrains-mono # Another excellent terminal font
      cascadia-code # Microsoft's terminal font
      ubuntu-classic # Ubuntu fonts
      dejavu_fonts # DejaVu fonts

      # Fallback fonts
      liberation_ttf
      freefont_ttf
    ];

    # Font configuration for better rendering
    fontconfig = {
      enable = true;
      antialias = true;
      hinting = {
        enable = true;
        style = "slight";
      };
      subpixel = {
        rgba = "rgb";
        lcdfilter = "default";
      };
      defaultFonts = {
        monospace = ["Fira Code Nerd Font" "JetBrains Mono" "Hack"];
        sansSerif = ["DejaVu Sans" "Liberation Sans"];
        serif = ["DejaVu Serif" "Liberation Serif"];
      };
    };
  };
}
