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
    ./core/neovim.nix
    ./core/virtualisation.nix
    ./core/git-repo-manager.nix
    ./core/screenshots.nix
  ];

  # Override warp-terminal to a specific upstream build.
  # TODO: replace url/hash with the .deb URL and sha256 for
  #       v0.2025.11.19.08.12.stable_03 (see README instructions).
  nixpkgs.overlays = [
    (final: prev: {
      warp-terminal = prev.warp-terminal.overrideAttrs (old: {
        version = "0.2025.11.19.08.12.stable_03";

        src = prev.fetchurl {
          url = "<FILL_IN_WARP_DEB_URL_HERE>";
          hash = "<FILL_IN_sha256_FROM_nix_store_prefetch-file>";
        };
      });
    })
  ];
}
