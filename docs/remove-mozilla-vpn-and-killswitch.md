# Removing Mozilla VPN and VPN Kill Switch from nixos-nymeria

This document captures the changes we made to remove Mozilla VPN and the nftables VPN kill switch from the NixOS configuration, so they can be reapplied on another branch.

The end state assumes **Cloudflare WARP only**, with no Mozilla VPN, no `vpn-killswitch` usage, and no Hyprland keybindings for Mozilla VPN.

## 1. Host imports (remove mozillavpn and vpn-killswitch)

File: `hosts/controlstackos/config.nix`

Update the imports list so it **no longer** includes `mozillavpn.nix` or `vpn-killswitch.nix`, and only keeps `cloudflare-warp.nix` for VPN-related functionality:

```nix
# Host-specific toggles and imports
imports = [
  ../../modules/core/networking.nix
  ../../modules/core/bootloader.nix
  ../../modules/core/cloudflare-warp.nix
];
```

If you see lines like these on the target branch, delete them:

```nix
../../modules/core/mozillavpn.nix
../../modules/core/vpn-killswitch.nix
```

Also remove any commented example like:

```nix
# my.vpnKillSwitch.enable = false;
```

## 2. Networking packages (drop mozillavpn)

File: `modules/core/packages/networking.nix`

Ensure the `environment.systemPackages` list **does not** contain `mozillavpn`. The final list should look like:

```nix
{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    dig
    iperf3
    nmap
    tcpdump
    traceroute
    mtr
    keepalived
    iftop
    ethtool
    openvswitch
    wireshark-cli
    wireguard-tools
  ];
}
```

If you see `mozillavpn` in this list on another branch, remove that entry.

## 3. Utilities packages (drop mozillavpn)

File: `modules/core/packages/utilities.nix`

Remove Mozilla VPN from the user-facing utilities list. The final form should **not** mention `mozillavpn` at all:

```nix
{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    btop
    tree
    fastfetch
    starship
    ghostty
    warp-terminal
    vivaldi
    vivaldi-ffmpeg-codecs
    widevine-cdm

    # Polkit agent (for authentication prompts in Wayland/Hyprland)
    lxqt.lxqt-policykit

    # Wayland-native screenshot and screen recording
    grim
    slurp
    swappy
    wl-screenrec
  ];
}
```

On branches that still have this block, delete the VPN section:

```nix
# VPN client
mozillavpn
```

## 4. Hyprland keybindings (remove Mozilla VPN shortcuts)

File: `modules/core/hyprland/keybindings.nix`

Remove the Mozilla VPN-specific bindings and comment, i.e. this block:

```nix
# Mozilla VPN controls
"$mainMod SHIFT, V, exec, vpn-toggle"
"$mainMod CTRL, V, exec, vpn-status notify"
```

After removal, the sequence around screenshots should look like:

```nix
", XF86AudioPrev, exec, playerctl previous"

# Screenshots
"$mainMod, Print, exec, screenshot-region"
"$mainMod SHIFT, Print, exec, screenshot-full"
```

No `vpn-toggle` or `vpn-status` references should remain.

## 5. Cloudflare WARP helper scripts (no Mozilla VPN coupling)

File: `modules/core/cloudflare-warp.nix`

We want WARP helpers that **do not** start/stop Mozilla VPN.

**Final `warp-on` definition:**

```nix
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
```

On the target branch, if you see any `warp-on`/`warp-off` logic that stops/starts `mozillavpn`, replace it with the version above.

## 6. Services comment cleanup

File: `modules/core/services.nix`

This is just a comment tweak so `upower` is not described as Mozilla-VPN-specific. The final snippet:

```nix
# Maintenance and firmware updates
services.fstrim.enable = true;
services.fwupd.enable = true;

# Power management DBus service required by some desktop apps (e.g., for battery and power status)
services.upower.enable = true;
```

On branches where the comment mentions "Mozilla VPN UI", update it to the wording above.

## 7. VPN cheat sheet docs (optional but recommended)

File: `docs/vpn-cheatsheet.md`

We converted this document from a "Mozilla VPN + WARP + kill switch" guide into a **Cloudflare WARP-only** guide. Key points:

- Title changed to: `# NixOS VPN Cheat Sheet (Cloudflare WARP)`
- Only Cloudflare WARP is described; Mozilla VPN commands were removed.
- All sections about the `vpn-killswitch` nftables rules were removed.
- The "Where things live" section references only:
  - `modules/core/cloudflare-warp.nix`
  - binaries: `warp-on`, `warp-off`
  - service: `warp-svc.service`

You can either:

- Reapply the edits by hand using this description, or
- Copy this file from the branch where it’s already updated once both branches exist and are in sync.

## 8. VPN kill switch module (no longer wired)

Files:
- `modules/core/vpn-killswitch.nix`
- `modules/core/mozillavpn.nix`

These modules now **exist but are not imported** from `hosts/controlstackos/config.nix`.

On the target branch you have two options:

1. **Keep them but leave them unused** (safe, and makes it easy to restore later by re-adding imports), or
2. **Delete the files** entirely if you are sure you will not use them again.

If you plan to keep the option to restore them later, option 1 is recommended.

---

## Reapply checklist on the correct branch

When you switch to the intended branch, reapply the changes by:

1. Editing `hosts/controlstackos/config.nix` to remove `mozillavpn.nix` and `vpn-killswitch.nix` from imports and keep only `cloudflare-warp.nix`.
2. Removing `mozillavpn` from `modules/core/packages/networking.nix` and `modules/core/packages/utilities.nix`.
3. Removing Mozilla VPN Hyprland bindings (`vpn-toggle`, `vpn-status`) from `modules/core/hyprland/keybindings.nix`.
4. Updating `modules/core/cloudflare-warp.nix` to match the `warp-on`/`warp-off` definitions in this document.
5. Updating the `upower` comment in `modules/core/services.nix`.
6. Optionally rewriting `docs/vpn-cheatsheet.md` as a WARP-only guide.
7. (Optional) Deciding whether to keep or delete `modules/core/mozillavpn.nix` and `modules/core/vpn-killswitch.nix`.

After reapplying, run:

```bash
nix flake check --no-build --impure
```

and then rebuild:

```bash
sudo nixos-rebuild switch --flake .#controlstackos
```
