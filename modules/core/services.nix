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

  # Thunderbolt security daemon
  services.hardware.bolt.enable = true;

  # Enable usbmuxd for iPhone/iOS device support (USB tethering, pairing)
  services.usbmuxd.enable = true;

  # Enable Snap daemon for installing Mozilla VPN client
  services.snapd.enable = true;

  # Maintenance and firmware updates
  services.fstrim.enable = true;
  services.fwupd.enable = true;
}
