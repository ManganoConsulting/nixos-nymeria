{
  config,
  pkgs,
  ...
}: {
  programs.firefox.enable = true;
  programs.zsh.enable = true;
  programs.virt-manager.enable = true;

  # Developer tooling
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
}
