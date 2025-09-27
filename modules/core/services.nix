{
  config,
  pkgs,
  ...
}: {
  services.openssh.enable = true;
  services.openssh.settings = {
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
    PermitRootLogin = "no";
  };

  services.logind = {
    lidSwitch = "ignore";
    lidSwitchExternalPower = "ignore";
    lidSwitchDocked = "ignore";
    powerKey = "ignore";
    rebootKey = "ignore";
    rebootKeyLongPress = "ignore";
    suspendKey = "ignore";
    hibernateKey = "ignore";
    suspendKeyLongPress = "ignore";
  };

  services.hardware.bolt.enable = true;

  # Maintenance and firmware updates
  services.fstrim.enable = true;
  services.fwupd.enable = true;
}
