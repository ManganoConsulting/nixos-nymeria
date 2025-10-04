{ config, pkgs, lib, ... }:

let
  vpnToggle = pkgs.writeShellScriptBin "vpn-toggle" ''
    #!/usr/bin/env bash
    set -euo pipefail

    # Decide action based on presence of any WireGuard interface
    if ${pkgs.wireguard-tools}/bin/wg show 2>/dev/null | grep -q '^interface: '; then
      action=deactivate
    else
      action=activate
    fi

    if ${pkgs.mozillavpn}/bin/mozillavpn "$action"; then
      state="$action"
      code=0
    else
      state=error
      code=1
    fi

    # On-screen feedback in Hyprland (non-blocking)
    if command -v hyprctl >/dev/null 2>&1; then
      case "$state" in
        activate)
          hyprctl notify 0 2500 "Mozilla VPN: activated" >/dev/null 2>&1 || true ;;
        deactivate)
          hyprctl notify 0 2500 "Mozilla VPN: deactivated" >/dev/null 2>&1 || true ;;
        *)
          hyprctl notify 2 4000 "Mozilla VPN: error (see logs)" >/dev/null 2>&1 || true ;;
      esac
    fi

    exit "$code"
  '';

  vpnStatus = pkgs.writeShellScriptBin "vpn-status" ''
    #!/usr/bin/env bash
    set -euo pipefail

    status="inactive"
    if ${pkgs.wireguard-tools}/bin/wg show 2>/dev/null | grep -q '^interface: '; then
      status="active"
    fi

    msg="Mozilla VPN: $status"
    if [[ ''${1:-} == notify ]] && command -v hyprctl >/dev/null 2>&1; then
      hyprctl notify 0 2000 "$msg" >/dev/null 2>&1 || true
    fi

    echo "$msg"
  '';

in {
  # Ensure mozillavpn is available system-wide and include helper scripts
  environment.systemPackages = [ pkgs.mozillavpn vpnToggle vpnStatus ];

  # Root daemon for Mozilla VPN
  systemd.services.mozillavpn = {
    description = "Mozilla VPN Linux Daemon";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.mozillavpn}/bin/mozillavpn linuxdaemon";
      Restart = "on-failure";
    };
  };
}
