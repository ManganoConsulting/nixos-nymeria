# Justfile
system := "x86_64-linux"

default: help

help:
	@just --list

fmt:
	nix fmt .

check:
	nix flake check --print-build-logs

update:
	nix flake update

# Helper to update the Warp overlay in modules/common.nix.
# Usage:
#   just update-warp 0.2025.11.19.08.12.stable_03
# This will print a ready-to-paste overlay snippet with version, url, and hash.
update-warp version:
	@warp_version="{{version}}"; \
	base_url="https://releases.warp.dev/stable/v$warp_version"; \
	file="warp-terminal-v$warp_version-1-x86_64.pkg.tar.zst"; \
	url="$base_url/$file"; \
	echo "Prefetching $url..." 1>&2; \
	hash=$(nix-prefetch-url --type sha256 "$url" | tail -n1); \
	sri=$(nix hash to-sri --type sha256 "$hash"); \
	echo; \
	echo "Paste this into modules/common.nix inside your warp-terminal overlay:"; \
	echo "        version = \"$warp_version\";"; \
	echo "        src = prev.fetchurl {"; \
	echo "          url = \"$url\";"; \
	echo "          hash = \"$sri\";"; \
	echo "        };"

switch:
	sudo nixos-rebuild switch --flake .#nymeria

vm:
	nix build .#nixosConfigurations.vm.config.system.build.vm
	./result/bin/run-nixos-vm
