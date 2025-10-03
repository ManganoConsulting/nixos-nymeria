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
        statusline.lualine.enable = true;
        telescope.enable = true;
        autocomplete.nvim-cmp.enable = true;
        debugger = {
          nvim-dap = {
            enable = true;
            ui.enable = true;
          };
        };
        lsp.enable = true;
        languages = {
          enableFormat = true;
          enableTreesitter = true;
          nix.enable = true;
          python = {
            enable = true;
            dap = {
              enable = true;
              debugger = "debugpy";
            };
            lsp = {
              enable = true;
              server = "basedpyright";
            };
          };
          rust = {
            enable = true;
            crates.enable = true;
          };
          go.enable = true;
          bash.enable = true;
        };
        filetree = {
          neo-tree = {
            enable = true;
          };
        };
        binds = {
          whichKey.enable = true;
        };
        utility = {
          surround.enable = true;
          yanky-nvim.enable = false;
        };
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
