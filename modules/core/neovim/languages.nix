{
  pkgs,
  lib,
  ...
}: {
  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        languages = {
          enableLSP = lib.mkForce false; # Handled by lsp.enable in plugins.nix
          enableFormat = lib.mkForce false; # Disable to avoid null-ls conflicts
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
