{
  config,
  pkgs,
  lib,
  ...
}: let
  # Helper to switch to Cloudflare WARP
  warpOn = pkgs.writeShellScriptBin "warp-on" ''
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Starting Cloudflare WARP service..."
    sudo systemctl start warp-svc

    # Ensure the device is registered (no-op if already registered)
    if ! sudo ${pkgs.cloudflare-warp}/bin/warp-cli --accept-tos status >/dev/null 2>&1; then
      echo "Registering this device with Cloudflare WARP..."
      sudo ${pkgs.cloudflare-warp}/bin/warp-cli --accept-tos register || true
    fi

    echo "Setting WARP mode and connecting..."
    sudo ${pkgs.cloudflare-warp}/bin/warp-cli --accept-tos set-mode warp || true
    sudo ${pkgs.cloudflare-warp}/bin/warp-cli --accept-tos connect

    echo "Cloudflare WARP is now active."
  '';

  # Helper to switch back off WARP
  warpOff = pkgs.writeShellScriptBin "warp-off" ''
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Disconnecting Cloudflare WARP..."
    sudo ${pkgs.cloudflare-warp}/bin/warp-cli --accept-tos disconnect || true

    echo "Stopping Cloudflare WARP service..."
    sudo systemctl stop warp-svc || true
  '';
in {
  # Install Cloudflare WARP (provides warp-cli and warp-svc) and helper scripts
  environment.systemPackages = [pkgs.cloudflare-warp warpOn warpOff];

  # Define the warp-svc daemon as a systemd unit, disabled by default
  systemd.services.warp-svc = {
    description = "Cloudflare WARP Linux Daemon";
    # Not enabled by default; start manually with: sudo systemctl start warp-svc
    wantedBy = [];
    after = ["network-online.target"];
    wants = ["network-online.target"];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.cloudflare-warp}/bin/warp-svc";
      Restart = "on-failure";
      # Basic hardening while allowing network configuration
      NoNewPrivileges = true;
      CapabilityBoundingSet = "CAP_NET_ADMIN CAP_NET_RAW";
      AmbientCapabilities = "CAP_NET_ADMIN CAP_NET_RAW";
      PrivateTmp = true;
      # Do not use ProtectSystem or ProtectHome here to avoid interfering with resolver management
    };
  };
}
