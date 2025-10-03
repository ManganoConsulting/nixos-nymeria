{ config, pkgs, ... }:

{
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
    extraConfig = ''
      Defaults env_keep += "SSH_AUTH_SOCK"
    '';
  };
}
