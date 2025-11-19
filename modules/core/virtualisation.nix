{
  config,
  pkgs,
  ...
}: {
  virtualisation = {
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;

    # Docker daemon for local container workloads
    docker = {
      enable = true;
      enableOnBoot = true;
      # Optional: add your main user to the docker group at system level
      # users.users.matthew.extraGroups = [ "docker" ];
    };
  };
}
