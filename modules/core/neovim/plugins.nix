{ pkgs, ... }:

{
  # System-wide Neovim configuration (This is required!)
  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        statusline.lualine.enable = true;
        telescope.enable = true;
        autocomplete.nvim-cmp.enable = true;
        debugger = {
          nvim-dap = {
            enable = true;
            ui.enable = true;
          };
        };
      };
    };
  };
}
