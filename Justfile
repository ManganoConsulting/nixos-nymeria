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

switch:
	sudo nixos-rebuild switch --flake .#nymeria

vm:
	nix build .#nixosConfigurations.vm.config.system.build.vm
	./result/bin/run-nixos-vm
