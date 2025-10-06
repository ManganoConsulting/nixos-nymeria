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

        # Extra plugins not covered by built-in NVF modules
        extraPlugins = with pkgs.vimPlugins; {
          toggleterm = {
            package = toggleterm-nvim;
            setup = "require('toggleterm').setup {}";
          };
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

          # ToggleTerm: floating terminal
          {
            key = "<leader>`";
            mode = ["n"];
            action = ":ToggleTerm direction=float<CR>";
            silent = true;
            desc = "ToggleTerm (float)";
          }
          {
            key = "<leader>`";
            mode = ["t"];
            action = "<C-\\><C-n>:ToggleTerm direction=float<CR>";
            silent = true;
            desc = "ToggleTerm (float)";
          }

          # ToggleTerm: horizontal split
          {
            key = "<leader>th";
            mode = ["n"];
            action = ":ToggleTerm direction=horizontal size=15<CR>";
            silent = true;
            desc = "ToggleTerm (horizontal)";
          }
          {
            key = "<leader>th";
            mode = ["t"];
            action = "<C-\\><C-n>:ToggleTerm direction=horizontal size=15<CR>";
            silent = true;
            desc = "ToggleTerm (horizontal)";
          }

          # ToggleTerm: vertical split
          {
            key = "<leader>tv";
            mode = ["n"];
            action = ":ToggleTerm direction=vertical size=80<CR>";
            silent = true;
            desc = "ToggleTerm (vertical)";
          }
          {
            key = "<leader>tv";
            mode = ["t"];
            action = "<C-\\><C-n>:ToggleTerm direction=vertical size=80<CR>";
            silent = true;
            desc = "ToggleTerm (vertical)";
          }
        ];
      };
    };
  };
}
