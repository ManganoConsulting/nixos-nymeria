{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./core/locale.nix
    ./core/users.nix
    ./core/packages.nix
    ./core/programs.nix
    ./core/services.nix
    ./core/security.nix
    ./core/system.nix
    ./core/sound.nix
    ./core/fonts.nix
    ./core/virtualisation.nix
    ./core/git-repo-manager.nix
  ];
}
