{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    btop
    tree
    fastfetch
    starship
  ];
}

