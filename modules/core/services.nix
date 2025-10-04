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

  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
    HandlePowerKey = "ignore";
    HandleRebootKey = "ignore";
    HandleRebootKeyLongPress = "ignore";
    HandleSuspendKey = "ignore";
    HandleHibernateKey = "ignore";
    HandleSuspendKeyLongPress = "ignore";
  };

  # Thunderbolt security daemon
  services.hardware.bolt.enable = true;

  # Enable usbmuxd for iPhone/iOS device support (USB tethering, pairing)
  services.usbmuxd.enable = true;

  # Maintenance and firmware updates
  services.fstrim.enable = true;
  services.fwupd.enable = true;

  # Power management DBus service required by some apps (e.g., Mozilla VPN UI)
  services.upower.enable = true;
}
