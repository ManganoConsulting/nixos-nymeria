# Install guide

## VMware VM (⚠ wipes target disk)
```bash
nix run github:nix-community/disko -- \
  --mode zap_create_mount \
  --flake <REPO_PATH>#nymeria-vmware
```

## KVM/QEMU VM (⚠ wipes target disk)
```bash
nix run github:nix-community/disko -- \
  --mode zap_create_mount \
  --flake <REPO_PATH>#nymeria-kvm
```

## Bare metal ZFS (⚠ wipes target disk)
1. Edit `modules/disko/baremetal-zfs-encrypted.nix` and replace the by-id device(s).
2. Then run:

```bash
nix run github:nix-community/disko -- \
  --mode zap_create_mount \
  --flake <REPO_PATH>#nymeria
```

After any of the above:
```bash
nixos-generate-config --root /mnt
```

Copy the generated hardware config into the matching host folder (only if it doesn't already exist or you're updating it):
```bash
cp /mnt/etc/nixos/hardware-configuration.nix <REPO_PATH>/hosts/<host>/hardware-configuration.nix
cd <REPO_PATH>
git add hosts/<host>/hardware-configuration.nix
git commit -m "chore(host): add hardware-configuration.nix for <host>"
```

Install:
```bash
nixos-install --flake <REPO_PATH>#<host>
```

Reboot, then from the installed system:
```bash
sudo nixos-rebuild switch --flake /etc/nixos#<host>
```

## Parametric one-off (override device on the fly)
```bash
nix run github:nix-community/disko -- \
  --mode zap_create_mount \
  --argstr device /dev/sda \
  --argstr pool rpool \
  --argstr ashift 12 \
  --config <REPO_PATH>/modules/disko/vm-zfs-generic.nix
```
