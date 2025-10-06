{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    wget
    git
    curl
    unzip
    home-manager
  ];
}
