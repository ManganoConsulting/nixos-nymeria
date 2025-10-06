{
  config,
  pkgs,
  ...
}: {
  # Recommended for Snap confinement
  security.apparmor.enable = true;

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
    extraConfig = ''
      Defaults env_keep += "SSH_AUTH_SOCK"
    '';
  };
}
