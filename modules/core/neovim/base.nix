{pkgs, ...}: {
  # System-wide Neovim configuration (This is required!)
  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        viAlias = false; # Disable vi alias
        vimAlias = true; # Enable vim alias (so vim opens nvim)
        theme = {
          enable = true;
          name = "gruvbox";
          style = "dark";
        };
      };
    };
  };
}
