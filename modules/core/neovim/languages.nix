{pkgs, ...}: {
  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        languages = {
          enableLSP = true;
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
          yaml.enable = true;
        };
      };
    };
  };
}
