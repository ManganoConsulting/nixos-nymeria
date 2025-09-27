{ config, pkgs, ... }:
{
  home.username = "matthew";
  home.homeDirectory = "/home/matthew";

  # User-level tooling and shell configs
  programs.zsh.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  # Match NixOS release used for this home config
  home.stateVersion = "25.05";
}
