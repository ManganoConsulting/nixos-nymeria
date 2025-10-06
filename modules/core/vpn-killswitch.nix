{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.vpnKillSwitch;

  # Always include loopback; add common VPN interface guesses by default
  defaultIfaces = ["moz0" "wgcf" "warp0" "tun0"];
  allowedIfaces = lib.unique (["lo"] ++ cfg.allowInterfaces);
  ifaceSet = lib.concatStringsSep ", " (map (i: "\"${i}\"") allowedIfaces);
  allowedIfacesStr = lib.concatStringsSep ", " allowedIfaces;

  toggleScript = pkgs.writeShellScriptBin "vpn-killswitch" ''
        #!/usr/bin/env bash
        set -euo pipefail

        FAMILY=inet
        TABLE=killswitch_runtime

        usage() {
          cat <<'USAGE'
    Usage: vpn-killswitch <enable|disable|status>

    - enable   Apply a runtime kill switch that only allows egress via: ${allowedIfacesStr}
    - disable  Remove the runtime kill switch
    - status   Show whether the runtime kill switch table exists

    Notes:
    - Enable AFTER your VPN is connected (e.g. mozillavpn activate or warp-on),
      otherwise initial handshakes may be blocked.
    - This runtime switch is ephemeral; it will be cleared on reboot.
    USAGE
        }

        cmd=''${1:-}
        case "$cmd" in
          enable)
            # Create table if missing
            if ! nft list table "$FAMILY" "$TABLE" >/dev/null 2>&1; then
              nft add table "$FAMILY" "$TABLE"
            fi
            # Add a constant set of allowed interfaces (lo + configured)
            if ! nft list set "$FAMILY" "$TABLE" allowed_ifaces >/dev/null 2>&1; then
              nft add set "$FAMILY" "$TABLE" allowed_ifaces '{ type ifname; flags constant; elements = { ${ifaceSet} } }'
            fi
            # Create output chain that drops any egress not via allowed_ifaces
            if ! nft list chain "$FAMILY" "$TABLE" output >/dev/null 2>&1; then
              nft add chain "$FAMILY" "$TABLE" output '{ type filter hook output priority 0; policy accept; }'
              nft add rule "$FAMILY" "$TABLE" output oifname != @allowed_ifaces drop comment "vpn-killswitch: drop non-VPN egress"
            else
              # Ensure our drop rule exists (idempotent-ish)
              if ! nft list chain "$FAMILY" "$TABLE" output | grep -q 'drop non-VPN egress'; then
                nft add rule "$FAMILY" "$TABLE" output oifname != @allowed_ifaces drop comment "vpn-killswitch: drop non-VPN egress"
              fi
            fi
            echo "[vpn-killswitch] enabled (allowed interfaces: ${allowedIfacesStr})"
            ;;
          disable)
            nft delete table "$FAMILY" "$TABLE" >/dev/null 2>&1 || true
            echo "[vpn-killswitch] disabled"
            ;;
          status)
            if nft list table "$FAMILY" "$TABLE" >/dev/null 2>&1; then
              echo "[vpn-killswitch] enabled"
              nft list table "$FAMILY" "$TABLE"
            else
              echo "[vpn-killswitch] disabled"
            fi
            ;;
          *)
            usage
            exit 1
            ;;
        esac
  '';
in {
  options.my.vpnKillSwitch = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable a strict VPN kill switch at boot using nftables. When enabled,
        all outbound traffic is dropped unless it egresses via an allowed
        interface (lo and the configured VPN interfaces). This is strict and
        can interfere with VPN handshakes if enabled before connecting.
      '';
    };

    allowInterfaces = mkOption {
      type = with types; listOf str;
      default = defaultIfaces;
      description = ''
        Interface names allowed for egress when the kill switch is active.
        Include your VPN interfaces here. Defaults include moz0 (Mozilla VPN)
        and common WireGuard tunnel names (wgcf, warp0, tun0). Loopback (lo)
        is always allowed implicitly.
      '';
      example = ["moz0" "wgcf"];
    };
  };

  config = mkMerge [
    {
      # Always install the runtime toggle script for quick on/off without rebuilds
      environment.systemPackages = [toggleScript];
    }

    (mkIf cfg.enable {
      # Declarative kill switch at boot (non-ephemeral). Disabled by default.
      networking.nftables.enable = true;
      networking.nftables.flushRuleset = mkDefault false;
      networking.nftables.tables.killswitch = {
        family = "inet";
        content = ''
          set allowed_ifaces {
            type ifname
            flags constant
            elements = { ${ifaceSet} }
          }

          chain output {
            type filter hook output priority 0; policy accept;
            oifname != @allowed_ifaces drop comment "vpn-killswitch: drop non-VPN egress"
          }
        '';
      };
    })
  ];
}
