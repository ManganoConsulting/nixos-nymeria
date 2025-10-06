{
  config,
  pkgs,
  ...
}: {
  services.openssh.enable = true;
  # Keep SSH on the non-standard port you chose
  services.openssh.ports = [3965];
  services.openssh.settings = {
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
    PermitRootLogin = "no";
  };

  # Enable Tailscale for NAT-traversing private networking
  services.tailscale.enable = true;

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

  # Git repository manager service
  services.git-repo-manager.enable = true;
  services.git-repo-manager.user = "matthew";
  services.git-repo-manager.syncOnBoot = true;
}
