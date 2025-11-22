{ ... }: {
  services.qemuGuestAgent.enable = true;
  zramSwap.enable = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
