{
  pkgs,
  lib,
  ...
}: {
  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        # Basic settings
        viAlias = false;
        vimAlias = true;

        # Theme
        theme = {
          enable = true;
          name = "gruvbox";
          style = "dark";
        };

        # Core functionality
        statusline.lualine.enable = true;
        telescope.enable = true;
        autocomplete.nvim-cmp.enable = true;

        # File tree and navigation
        filetree.neo-tree.enable = true;
        binds.whichKey.enable = true;

        # Utilities
        utility = {
          surround.enable = true;
          yanky-nvim.enable = false;
        };

        # Language support (simplified to avoid conflicts)
        languages = {
          enableTreesitter = true;
          # Individual language configs
          nix.enable = true;
          python.enable = true;
          rust.enable = true;
          go.enable = true;
          bash.enable = true;
          yaml.enable = true;
        };

        # Debugging
        debugger = {
          nvim-dap = {
            enable = true;
            ui.enable = true;
          };
        };

        # Custom keymaps
        keymaps = [
          {
            key = "<leader>wq";
            mode = ["n"];
            action = ":wq<CR>";
            silent = true;
            desc = "Save file and quit";
          }
          {
            key = "<leader>e";
            mode = ["n"];
            action = ":Neotree focus<CR>";
            silent = true;
            desc = "Neotree Focus";
          }
        ];
      };
    };
  };
}
