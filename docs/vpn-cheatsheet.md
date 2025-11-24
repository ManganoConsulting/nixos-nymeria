# NixOS VPN Cheat Sheet (Cloudflare WARP)

Purpose
- Protect traffic on untrusted networks (e.g., hotel Wi‑Fi).
- Use Mozilla VPN as primary, Cloudflare WARP as backup.
- Optionally enforce a strict kill switch that only allows traffic over VPN interfaces.

Key components installed
- Cloudflare WARP CLI + service: warp-cli, warp-svc (service: warp-svc.service)
- Helper scripts:
  - warp-on: start WARP service, register if needed, connect
  - warp-off: disconnect and stop WARP

General rules
- If you use WARP, don’t also run other VPNs that manipulate the default route at the same time.

Quick reference: Cloudflare WARP
- Switch to WARP (starts WARP, registers if needed, connects):
  - warp-on
- Leave WARP:
  - warp-off
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


Typical workflows
1) Use Cloudflare WARP
   - warp-on
   - Verify connectivity via Cloudflare trace (see below)

2) Leave Cloudflare WARP
   - warp-off

Verification tips
- Check egress + WARP state:
  - curl -s https://www.cloudflare.com/cdn-cgi/trace | grep -E 'warp|ip|colo'
- Inspect interfaces and default route:
  - ip -o link
  - ip route
- DNS diagnostics (systemd-resolved environments):
  - resolvectl status

Troubleshooting
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
- Helper binaries (in PATH):
  - /run/current-system/sw/bin/warp-on
  - /run/current-system/sw/bin/warp-off
- Services:
  - warp-svc.service (installed, not auto-started)

Security notes
- Avoid running multiple VPNs that both manage default routes at the same time; prefer one active VPN provider at once.

Change allowed interfaces
- For runtime mode, defaults are sufficient for most setups.
- For persistent mode, set my.vpnKillSwitch.allowInterfaces = [ ... ]; and rebuild.
