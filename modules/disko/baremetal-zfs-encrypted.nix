{ ... }:
let
  disk0 = "/dev/disk/by-id/REPLACE_ME";
in
{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = disk0;
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "512MiB"; type = "EF00";
            content = { type = "filesystem"; format = "vfat"; mountpoint = "/boot"; };
          };
          zfs = {
            size = "100%";
            content = { type = "zfs"; pool = "rpool"; };
          };
        };
      };
    };

    # For mirror (example):
    # disk.mirror1 = { ... same with device = "/dev/disk/by-id/REPLACE_ME_2"; content = { type="gpt"; ... }; }

    zpool.rpool = {
      type = "zpool";
      mode = "single"; # change to "mirror" and list both disks in members if you add mirror devices
      options = { ashift = "12"; autotrim = "on"; };
      rootFsOptions = {
        atime = "off"; compression = "zstd"; xattr = "sa"; acltype = "posixacl"; mountpoint = "none";
      };
      datasets = {
        "rpool/root" = {
          type = "zfs_fs"; mountpoint = "/";
          options = { canmount = "noauto"; encryption = "on"; keyformat = "passphrase"; keylocation = "prompt"; };
        };
        "rpool/nix"  = { type = "zfs_fs"; mountpoint = "/nix"; };
        "rpool/home" = { type = "zfs_fs"; mountpoint = "/home"; };
        "rpool/var_log" = { type = "zfs_fs"; mountpoint = "/var/log"; };
        # "rpool/swap" = { type = "zfs_zvol"; size = "16G"; options = { compression = "zle"; sync = "always"; logbias = "throughput"; }; };
      };
    };
  };
}
