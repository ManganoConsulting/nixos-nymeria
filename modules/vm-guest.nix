{...}: {
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
  virtualisation.qemu.guestAgent.enable = true;
}
