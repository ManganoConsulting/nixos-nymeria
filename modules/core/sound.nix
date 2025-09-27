{ config, pkgs, ... }:

{
  # Enable PipeWire
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;  # Enable JACK support
  };

  # Ensure PipeWire replaces PulseAudio
  security.rtkit.enable = true;

  # Enable Bluetooth audio (optional)
  hardware.bluetooth.enable = true;
  hardware.bluetooth.package = pkgs.bluez;
  services.blueman.enable = true;
}

