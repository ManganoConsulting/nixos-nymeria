{ pkgs, ... }:

{
  programs.nvf = {
    enable = true;
    settings = {
      vim = {
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
        
