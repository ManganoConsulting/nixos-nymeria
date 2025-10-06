# Warp AI (GPT-5) Prompt — NixOS Flake Refactor to a “Golden” Layout

**Role:** You are a senior NixOS/Nix Flakes engineer.  
**Mission:** Audit and refactor a NixOS flake repo to a clean, repeatable, multi-host layout with Home-Manager as a NixOS module, secrets via sops-nix, optional disko/nixos-hardware, perSystem devshell + checks, CI, and a sane `.gitignore`.  
**Repo:** `https://github.com/ManganoConsulting/nixos-nymeria.git`  
**Primary host name:** `nymeria` (laptop)  
**User:** `matthew`  
**Timezone:** `America/Los_Angeles`

---

## Deliverables
- A PR titled: **“refactor: golden flake layout + HM + sops-nix + CI”**
- Updated `flake.nix`/`flake.lock`, new `hosts/` layout, `modules/` split, `home/` wiring, `.gitignore`, `.github/workflows/nix.yml`
- Optional: `hosts/nymeria/disko.nix` and `nixos-hardware` hook
- Dev shell, formatter, checks (`alejandra`, `statix`, `deadnix`)
- Migration notes in `docs/REFRESH.md`
- Commands section to test, install, or VM-boot

---

## Constraints & Conventions
- Do **not** commit private keys or decrypted secrets.
- Keep `system.stateVersion` pinned (don’t bump).
- Use small, composable modules; no monoliths.
- Commit messages: conventional commits (`refactor:`, `feat:`, `chore:`).
- Prefer stable channels (`nixos-24.05`) unless a package requires unstable.

---

## Numbered Tasks (execute in order)

1) **Repo audit & safety**
   - Clone repo locally.
   - Detect if `result`, `result-*`, or other build outputs are tracked. If yes, plan removal and add `.gitignore`.
   - Note presence of root `configuration.nix` / `hardware-configuration.nix` (legacy files).

2) **Restructure to `hosts/` layout**
   - Create:
     ```
     hosts/nymeria/{config.nix,hardware-configuration.nix}
     modules/{common.nix,desktop.nix,vm-guest.nix}
     home/matthew.nix
     docs/REFRESH.md
     ```
   - Migrate any settings from root `configuration.nix` → `hosts/nymeria/config.nix` and `modules/common.nix` (networking, users, nix settings, base pkgs).
   - Keep host-specific hardware in `hosts/nymeria/hardware-configuration.nix`.

3) **`.gitignore` & cleanup**
   - Create/update `.gitignore`:
     ```
     result
     result-*
     .direnv/
     .devenv/
     *.qcow2
     *.drv
     *.swp
     .envrc
     .sops.yaml~
     ```
   - If `result` or other build artifacts are tracked, run:
     ```bash
     git rm -r --cached result result-* || true
     ```
     (If large or deep in history, note optional `git filter-repo` plan in `docs/REFRESH.md`.)

4) **Home-Manager as a NixOS module**
   - Add `home-manager` flake input and wire it inside the `nixosSystem` modules for `nymeria`.
   - Ensure user config lives in `home/matthew.nix` and activates on first boot.

5) **Secrets with sops-nix**
   - Add `sops-nix` flake input.
   - Add a top-level `.sops.yaml` (policy) and `secrets/` (encrypted payloads).
   - Generate an AGE key pair **locally** (do not commit private key):
     ```bash
     age-keygen -o ~/.config/sops/age/keys.txt
     grep public ~/.config/sops/age/keys.txt
     ```
   - Put the **public** AGE key in `.sops.yaml` recipients.
   - Example secret mapping in `hosts/nymeria/config.nix` (use `config.sops.secrets.<name>.path`).

6) **Optional: nixos-hardware & disko (declarative partitioning)**
   - Add `nixos-hardware` input and (if applicable) the correct module for the laptop model.
   - Add `disko` input and provide a sample `hosts/nymeria/disko.nix` commented for later use.

7) **Modules split & quality defaults**
   - `modules/common.nix`: nix experimental features, time zone, locale, user `matthew`, groups, SSH, NetworkManager, base packages, direnv.
   - `modules/desktop.nix`: display manager + DE/WM (example provided), PipeWire, Bluetooth, fonts, fwupd.
   - `modules/vm-guest.nix`: `qemuGuest`, `spice-vdagent`, guest agent toggles.

8) **perSystem dev shell, formatter, and checks**
   - Add `devShells.default` with `git sops age just statix deadnix alejandra`.
   - `formatter = pkgs.alejandra`.
   - `checks.default` to run `statix` + `deadnix`.

9) **GitHub Actions CI**
   - Add `.github/workflows/nix.yml` to run `nix flake check` on PRs and pushes.

10) **Smoke tests & docs**
   - `nix fmt` (alejandra) and `nix flake check`.
   - Build and launch a VM from `.#nixosConfigurations.vm` (if present).
   - Update `docs/REFRESH.md` with exact commands to install/rebuild on new machines and VM quick-start.

---

## File & Snippet Templates (apply or merge as needed)

### `flake.nix`
```nix
{
  description = "Repeatable NixOS + Home Manager with flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";

    # optional
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    disko.url = "github:nix-community/disko";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, sops-nix, nixos-hardware, disko, ... }:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";

      mkHost = modules:
        lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = modules ++ [
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.matthew = import ./home/matthew.nix;
            }
            sops-nix.nixosModules.sops
          ];
        };

      perSystem = pkgs: {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [ git sops age just statix deadnix alejandra ];
        };
        formatter = pkgs.alejandra;
        checks.default = pkgs.stdenv.mkDerivation {
          name = "lint";
          src = ./.;
          buildCommand = ''
            ${pkgs.statix}/bin/statix check .
            ${pkgs.deadnix}/bin/deadnix --fail .
            mkdir -p $out
          '';
        };
      };
    in {
      nixosConfigurations = {
        nymeria = mkHost [
          ./hosts/nymeria/hardware-configuration.nix
          ./modules/common.nix
          ./modules/desktop.nix
          ./hosts/nymeria/config.nix
          # optional: a specific hardware profile, uncomment and pick your model:
          # nixos-hardware.nixosModules.lenovo-thinkpad-x1-9th-gen
          # optional: disko.nixosModules.disko
        ];

        # Example VM profile (optional)
        vm = mkHost [
          ./modules/common.nix
          ./modules/vm-guest.nix
          # ./hosts/vm/config.nix
        ];
      };

      # per-system outputs (formatter, checks, devshell)
      devShells.${system}.default = (perSystem (import nixpkgs { inherit system; })).devShells.default;
      formatter.${system} = (perSystem (import nixpkgs { inherit system; })).formatter;
      checks.${system}.default = (perSystem (import nixpkgs { inherit system; })).checks.default;
    };
}
```

### `modules/common.nix`
```nix
{ config, pkgs, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.matthew = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
  };

  services.openssh.enable = true;
  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [
    git git-lfs gnupg curl wget vim neovim htop jq unzip ripgrep fd bat delta direnv nix-direnv
  ];

  programs = {
    zsh.enable = true;
    direnv.enable = true;
    direnv.nix-direnv.enable = true;
  };

  services.fwupd.enable = true;

  system.stateVersion = "24.05";
}
```

### `modules/desktop.nix`
```nix
{ config, pkgs, ... }:
{
  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true; # swap for GNOME/Hyprland if desired

  hardware.bluetooth.enable = true;
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    jack.enable = true;
  };

  fonts.packages = with pkgs; [ (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; }) ];
}
```

### `modules/vm-guest.nix`
```nix
{ ... }:
{
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
  virtualisation.qemu.guestAgent.enable = true;
}
```

### `hosts/nymeria/config.nix`
```nix
{ config, pkgs, ... }:
{
  # Host-specific toggles or imports can go here.
  # Example: custom kernel modules, power management, wifi firmware, etc.
}
```

### `home/matthew.nix`
```nix
{ config, pkgs, ... }:
{
  home.username = "matthew";
  home.homeDirectory = "/home/matthew";

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "Matthew Mangano";
    userEmail = "you@example.com";
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  home.packages = with pkgs; [ ];

  home.stateVersion = "24.05";
}
```

### `.sops.yaml`
```yaml
# Do not commit private keys. Put AGE private key in ~/.config/sops/age/keys.txt
creation_rules:
  - path_regex: secrets/.*\.(yaml|yml|json|env)$
    encrypted_regex: '^(data|stringData|password|secret|token)$'
    age: 
      - age1PUT_YOUR_PUBLIC_AGE_KEY_HERE
```

### Example secret usage (add to `hosts/nymeria/config.nix`)
```nix
{ config, ... }:
{
  sops.secrets."example-password".sopsFile = ./../../secrets/example.yaml;

  # Use it:
  # services.postgresql.authentication = {
  #   enable = true;
  #   passwordFile = config.sops.secrets."example-password".path;
  # };
}
```

### `.github/workflows/nix.yml`
```yaml
name: nix
on: [push, pull_request]
jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: cachix/install-nix-action@v27
        with:
          extra_nix_config: experimental-features = nix-command flakes
      - run: nix flake check
```

### `.gitignore`
```gitignore
result
result-*
.direnv/
.devenv/
*.qcow2
*.drv
*.swp
.envrc
.sops.yaml~
```

### `docs/REFRESH.md` (outline)
```markdown
# Refresh / Install

## Update inputs and rebuild
```bash
nix flake update
sudo nixos-rebuild switch --flake .#nymeria
```

## New machine install (manual partition)
1. Boot ISO, connect network.
2. Clone repo: `git clone <your repo> && cd <repo>`
3. Copy generated hardware config to `hosts/<host>/hardware-configuration.nix`
4. `sudo nixos-install --flake .#<host>`
5. Reboot.

## Declarative partition (optional, disko)
```bash
nix run github:nix-community/disko -- --mode disko ./hosts/<host>/disko.nix
sudo nixos-install --flake .#<host>
```

## VM smoke test
```bash
nix build .#nixosConfigurations.vm.config.system.build.vm
./result/bin/run-nixos-vm
```
```

---

## Commands Warp can run during the refactor (safe sequence)

```bash
# 0) Prep
gh repo clone ManganoConsulting/nixos-nymeria
cd nixos-nymeria
git checkout -b refactor/flake-structure

# 1) Create directories
mkdir -p hosts/nymeria modules home docs .github/workflows secrets

# 2) Move legacy files if present
[ -f hardware-configuration.nix ] && git mv hardware-configuration.nix hosts/nymeria/hardware-configuration.nix
# config will be split; keep legacy for reference during migration:
# [ -f configuration.nix ] && git mv configuration.nix legacy-configuration.nix

# 3) Write/update files from templates (as above)

# 4) Ignore build outputs
cat > .gitignore <<'EOF'
result
result-*
.direnv/
.devenv/
*.qcow2
*.drv
*.swp
.envrc
.sops.yaml~
EOF

# 5) Format & check
nix fmt || true
nix flake check

# 6) Commit & push
git add -A
git commit -m "refactor: golden flake layout, HM module, sops-nix, CI, devshell"
git push -u origin refactor/flake-structure

# 7) Open PR
gh pr create --fill --title "refactor: golden flake layout + HM + sops-nix + CI" --body "Refactors to multi-host flake layout; integrates Home-Manager as NixOS module; adds sops-nix; CI; devshell; .gitignore; docs."
```

---

## Notes / Gotchas
- Keep `system.stateVersion` at the value from your first 24.05 install.
- For secrets: commit only encrypted files under `secrets/`. Never commit AGE private key.
- If using Hyprland or NVIDIA: put those toggles in a separate module and import per-host.
- Consider adding `impermanence` later if you want a mostly-stateless root with persisted dirs.

---

**End of Prompt**
