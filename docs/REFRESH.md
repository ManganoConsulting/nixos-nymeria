# Refresh / Install

These are the common commands to rebuild, install, and smoke-test the system after this refactor.

## Update inputs and rebuild (local)
```bash
# Update flake inputs
nix flake update

# Format Nix files
nix fmt .

# Build + switch to nymeria configuration
sudo nixos-rebuild switch --flake .#nymeria
```

## New machine install (manual partition)
1. Boot the NixOS ISO and connect to the network.
2. Clone your repo:
   ```bash
   git clone git@github.com:ManganoConsulting/nixos-nymeria.git
   cd nixos-nymeria
   ```
3. Generate hardware config and copy it into hosts/nymeria:
   ```bash
   sudo nixos-generate-config --show-hardware-config > hosts/nymeria/hardware-configuration.nix
   ```
4. Install:
   ```bash
   sudo nixos-install --flake .#nymeria
   ```
5. Reboot.

## Declarative partition (optional, disko)
```bash
# Review and edit hosts/nymeria/disko.nix to match your disk(s) first
nix run github:nix-community/disko -- --mode disko ./hosts/nymeria/disko.nix
sudo nixos-install --flake .#nymeria
```

## VM smoke test
You can build a QEMU VM from the nymeria config (useful for quick checks):
```bash
nix build .#nixosConfigurations.nymeria.config.system.build.vm
./result/bin/run-nixos-vm
```

## Secrets (sops-nix)
- AGE private key should live only at: ~/.config/sops/age/keys.txt (do not commit)
- Example to create a secret file:
  ```bash
  sops -e --input-type yaml --output secrets/example.yaml /dev/stdin <<'YAML'
  password: change-me
  YAML
  git add secrets/example.yaml
  ```
- Reference in hosts/nymeria/config.nix (uncomment the example) and use `config.sops.secrets.<name>.path` in services.

## Useful flake commands
```bash
# Lint (defined in flake checks)
nix flake check

# Dev shell with tools (statix, deadnix, alejandra, etc.)
nix develop

# Format all Nix files via flake formatter
nix fmt .
```
