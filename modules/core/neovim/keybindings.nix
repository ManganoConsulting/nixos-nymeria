{pkgs, ...}: {
  programs.nvf = {
    settings = {
      vim = {
        # File tree and utility keybindings
        filetree.neo-tree.enable = true;
        binds.whichKey.enable = true;
        utility.surround.enable = true;
        
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
