{pkgs, lib, ...}: {
  programs.nvf = {
    settings = {
      vim = {
        # Status line
        statusline.lualine.enable = true;
        
        # Telescope fuzzy finder  
        telescope.enable = true;
        
        # Autocompletion
        autocomplete.nvim-cmp.enable = true;
        
        # LSP (force enable to resolve conflicts)
        lsp = {
          enable = lib.mkForce true;
          formatOnSave = lib.mkForce false; # Disable to avoid null-ls conflicts
        };
        
        # Debugging
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
