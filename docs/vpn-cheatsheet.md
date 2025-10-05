# NixOS VPN + Kill Switch Cheat Sheet (Mozilla VPN + Cloudflare WARP)

Purpose
- Protect traffic on untrusted networks (e.g., hotel Wi‑Fi).
- Use Mozilla VPN as primary, Cloudflare WARP as backup.
- Optionally enforce a strict kill switch that only allows traffic over VPN interfaces.

Key components installed
- Mozilla VPN service + CLI: mozillavpn (service: mozillavpn.service)
- Cloudflare WARP CLI + service: warp-cli, warp-svc (service: warp-svc.service)
- Helper scripts:
  - warp-on: stop Mozilla VPN, start WARP service, register if needed, connect
  - warp-off: disconnect and stop WARP, start Mozilla VPN
  - vpn-killswitch: runtime-only toggle for nftables kill switch (enable/disable/status)

General rules
- Don’t run Mozilla VPN and WARP at the same time. Use the helper scripts to switch.
- If using the kill switch, enable it AFTER the VPN is connected (otherwise the handshake may be blocked).

Quick reference: Mozilla VPN (primary)
- Connect:
  - mozillavpn activate
- Disconnect:
  - mozillavpn deactivate
- Status:
  - mozillavpn status
- Choose server (optional):
  - mozillavpn servers
  - mozillavpn select <server-id>

Quick reference: Cloudflare WARP (backup)
- Switch to WARP (stops Mozilla VPN, starts WARP, registers, connects):
  - warp-on
- Leave WARP and go back to Mozilla VPN:
  - warp-off
  - mozillavpn activate
- Check WARP status:
  - warp-cli --accept-tos status
- Manual operations if needed:
  - warp-cli --accept-tos register
  - warp-cli --accept-tos set-mode warp
  - warp-cli --accept-tos connect
  - warp-cli --accept-tos disconnect
- Service management:
  - systemctl status --no-pager warp-svc
  - sudo systemctl start|stop warp-svc

Kill switch (nftables)
- Runtime (ephemeral) toggle — no rebuild needed:
  - Enable (after VPN is connected):
    - vpn-killswitch enable
  - Disable:
    - vpn-killswitch disable
  - Status:
    - vpn-killswitch status
  - Notes:
    - Only allows egress on interfaces: lo + ["moz0", "wgcf", "warp0", "tun0"] by default.
    - This runtime table is cleared on reboot (non-persistent).

- Persistent (declarative) option — requires rebuild:
  - In your NixOS configuration you can set:
    my.vpnKillSwitch.enable = true;
    my.vpnKillSwitch.allowInterfaces = [ "moz0" "wgcf" "warp0" "tun0" ];
  - Then rebuild the system. This applies the kill switch at boot.
  - Default remains disabled to keep behavior non-invasive unless explicitly enabled.

Typical workflows
1) Use Mozilla VPN (recommended default)
   - mozillavpn activate
   - Optional: vpn-killswitch enable
   - Verify: mozillavpn status

2) Switch from Mozilla VPN to WARP
   - vpn-killswitch disable   # if enabled
   - warp-off                 # ensure Mozilla is stopped (idempotent)
   - warp-on                  # starts WARP and connects
   - Optional: vpn-killswitch enable

3) Switch back from WARP to Mozilla VPN
   - vpn-killswitch disable
   - warp-off
   - mozillavpn activate
   - Optional: vpn-killswitch enable

Verification tips
- Check egress + WARP state:
  - curl -s https://www.cloudflare.com/cdn-cgi/trace | grep -E 'warp|ip|colo'
- Inspect interfaces and default route:
  - ip -o link
  - ip route
- DNS diagnostics (systemd-resolved environments):
  - resolvectl status

Troubleshooting
- No connectivity right after enabling kill switch:
  - The VPN handshake may have been blocked. Do:
    - vpn-killswitch disable
    - Connect VPN (mozillavpn activate or warp-on)
    - vpn-killswitch enable
- WARP not registered:
  - warp-cli --accept-tos register
  - warp-cli --accept-tos connect
- Find your VPN interface names:
  - ip -o link | grep -E 'moz|wg|warp|tun'
  - If WARP uses a different name than wgcf/warp0/tun0, add it to allowed interfaces (see below) or use runtime mode.
- Emergency disable (runtime rules):
  - sudo nft delete table inet killswitch_runtime
- Persistent mode locked you out:
  - Reboot into previous NixOS generation (from boot menu) and set my.vpnKillSwitch.enable = false; then rebuild.

Where things live (repo + system)
- Modules added:
  - modules/core/cloudflare-warp.nix
  - modules/core/vpn-killswitch.nix
- Helper binaries (in PATH):
  - /run/current-system/sw/bin/warp-on
  - /run/current-system/sw/bin/warp-off
  - /run/current-system/sw/bin/vpn-killswitch
- Services:
  - mozillavpn.service (enabled)
  - warp-svc.service (installed, not auto-started)

Security notes
- The kill switch prevents accidental leaks if the VPN drops, but only for the interfaces you approve. Keep the allow list tight.
- Avoid running both VPNs simultaneously; switching scripts handle clean transitions.

Change allowed interfaces
- For runtime mode, defaults are sufficient for most setups.
- For persistent mode, set my.vpnKillSwitch.allowInterfaces = [ ... ]; and rebuild.
