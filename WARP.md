# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Repository Overview

This is a personal NixOS system configuration for a machine named "nymeria". It's structured as a Nix flake that defines a complete NixOS system configuration using a modular approach.

## Key Commands

### Building and Testing
```bash
# Build the configuration without switching (for testing)
sudo nixos-rebuild build --flake .#nymeria

# Switch to the new configuration
sudo nixos-rebuild switch --flake .#nymeria

# Test the configuration (temporary, reverts on reboot)
sudo nixos-rebuild test --flake .#nymeria

# Update flake inputs (like updating package repositories)
nix flake update

# Check what will be updated/changed
nixos-rebuild dry-build --flake .#nymeria
```

### Development Commands
```bash
# Enter a development shell with nix tools
nix develop

# Check flake structure and outputs
nix flake show

# Garbage collect old generations (free up disk space)
sudo nix-collect-garbage -d

# List system generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
```

## Architecture

### Core Structure
- **flake.nix**: Entry point defining the NixOS system configuration "nymeria"
- **configuration.nix**: Main configuration file that imports all modules
- **hardware-configuration.nix**: Auto-generated hardware-specific settings (do not edit)
- **modules/core/**: Modular system configuration organized by function

### Module Organization
The system is broken down into focused modules under `modules/core/`:

- **bootloader.nix**: System boot configuration
- **networking.nix**: Network settings and configuration  
- **users.nix**: User accounts and permissions (primary user: "matthew")
- **packages/**: Package management split by category
  - `core.nix`: Essential system packages (git, wget, curl, etc.)
  - `dev-tools.nix`: Development tools (gcc, tmux, languages, k8s tools)
  - `networking.nix`: Network-related packages
  - `system-tools.nix`: System administration tools
  - `utilities.nix`: General utility packages
- **programs.nix**: System-wide program configurations (Firefox, Hyprland, zsh)
- **neovim.nix**: Comprehensive Neovim configuration using nvf flake
- **services.nix**: System services configuration
- **hyprland/**: Wayland compositor configuration (currently disabled)
  - Split into focused files: base, monitors, keybindings, appearance, etc.

### Key Technologies
- **NixOS**: Declarative Linux distribution
- **Nix Flakes**: Modern dependency management and reproducible builds
- **nvf**: Neovim configuration framework for Nix
- **Hyprland**: Wayland compositor (optional, currently commented out)
- **Home Manager**: User environment management

### Configuration Philosophy
- **Modular Design**: Each system aspect is isolated in its own module
- **Declarative**: Everything is defined in code, no manual configuration
- **Reproducible**: The exact system state can be rebuilt from these files
- **Version Controlled**: All configuration changes are tracked in git

### Neovim Configuration
The system includes a comprehensive Neovim setup via nvf with:
- Language support for Nix, Python, Rust, Go, Bash
- LSP, formatting, and debugging configured
- Telescope, neo-tree, and modern editing features
- Gruvbox theme with lualine statusline

## Working with This Configuration

When modifying the configuration:
1. Edit the relevant module files under `modules/core/`
2. Test changes with `nixos-rebuild build --flake .#nymeria` 
3. Apply with `nixos-rebuild switch --flake .#nymeria`
4. Commit changes to version control

The system uses unfree packages (`nixpkgs.config.allowUnfree = true`) and experimental Nix features (flakes and nix-command).