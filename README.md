# NixOS • nymeria

[![nix](https://github.com/ManganoConsulting/nixos-nymeria/actions/workflows/nix.yml/badge.svg)](https://github.com/ManganoConsulting/nixos-nymeria/actions/workflows/nix.yml)

A golden flake for my laptop host "nymeria" with:

- Home Manager wired as a NixOS module
- sops-nix for secrets (AGE)
- Clean flake outputs (dev shell, formatter, checks)
- CI running `nix flake check` and format checks
- Fast VM smoke tests via a dedicated `vm` config

> Timezone: America/Los_Angeles • User: matthew

---

## Status / Roadmap

**Goal:** A golden NixOS flake for the _nymeria_ laptop that works identically on hardware and QEMU VMs, with declarative disk layout (disko), sops-nix secrets, Home Manager user environment, and a near-automatic install/upgrade flow.

**Completed**
- [x] Flake structure with hardware + VM configs
- [x] sops-nix for secrets
- [x] Home Manager as user environment
- [x] Neovim (NVF) with plugins + LSPs
- [x] SSH hardening + Tailscale
- [x] GC + optimisation timers

**In Progress**
- [ ] Integrate `disko.nixosModules.disko` into the host build
- [ ] Create a true “installer” flake output or `just install` target
- [ ] Make Rust + Node toolchains fully declarative
- [ ] Add laptop-specific power management (tlp or power-profiles-daemon)
- [ ] Add automated system upgrades (`system.autoUpgrade` or a service)
- [ ] Split hardware-heavy services out of `modules/common.nix` for cleaner VM builds

---

## Features

- NixOS with flakes enabled
- Home Manager integrated inside NixOS
- sops-nix configured with a repo `.sops.yaml`
- Dev shell with formatting and lint tools
- Checks that build the host and VM
- GitHub Actions CI
- Optional Cachix wiring in CI

---

## Quick start

Ensure you have Nix with flakes enabled.

Update inputs and rebuild the host:

```bash
nix flake update
sudo nixos-rebuild switch --flake .#nymeria
```

New machine install (manual partition):

1. Boot the NixOS ISO and connect to the network.
2. Clone the repo:
   ```bash
   git clone git@github.com:ManganoConsulting/nixos-nymeria.git
   cd nixos-nymeria
   ```
3. Copy the generated hardware config:
   ```bash
   sudo nixos-generate-config \
     --show-hardware-config \
     > hosts/nymeria/hardware-configuration.nix
   ```
4. Install:
   ```bash
   sudo nixos-install --flake .#nymeria
   ```
5. Reboot.

---

## VM smoke test

Build a quick QEMU VM for local smoke tests:

```bash
nix build .#nixosConfigurations.vm.config.system.build.vm
./result/bin/run-nixos-vm
```

With more CPU or RAM:

```bash
QEMU_OPTS="-smp 4 -m 4096" ./result/bin/run-nixos-vm
```

If you use `just`, there is a shortcut:

```bash
just vm
```

---

## Dev shell

Enter a dev shell with common tools and hooks:

- alejandra (formatter)
- statix (lint)
- deadnix (lint)
- nil (Nix LSP)
- nix-output-monitor
- pre-commit

```bash
nix develop
```

On shell entry, pre-commit hooks are installed automatically.
You can run the full suite on demand with:

```bash
nix build .#packages.x86_64-linux.pre-commit-check
```

---

## Repo layout

- `flake.nix`        — inputs, outputs, host defs, dev shell, checks
- `hosts/nymeria/`   — host config and hardware details
- `modules/`         — shared NixOS modules (core, desktop, vm-guest)
- `home/`            — Home Manager config for the user
- `docs/REFRESH.md`  — rebuild, install, and VM notes
- `secrets/`         — encrypted files (do not commit private keys)
- `.github/workflows/nix.yml` — CI

---

## CI

GitHub Actions runs:

- `nix fmt -- --check`
- `nix flake check --print-build-logs`
- Optional Cachix cache (set `CACHIX_AUTH_TOKEN`)
- A daily lockfile update PR

---

## Secrets (sops-nix)

- The repo contains `.sops.yaml` with an AGE recipient.
- Your AGE private key must remain local.
- Keep it in `~/.config/sops/age/keys.txt`.

Example secret mapping is included in `hosts/nymeria/config.nix`.
It is gated by file existence to avoid failing builds.

---

## Contributing / local workflow

- Format Nix files:
  ```bash
  nix fmt .
  ```
- Lint and checks:
  ```bash
  nix flake check --print-build-logs
  ```
- Common commands via `just`:
  ```bash
  just
  ```

---

## License

Choose a license for this repository.
Add a `LICENSE` file when decided.
