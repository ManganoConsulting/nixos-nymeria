# modules/disko/vm-zfs-generic.nix
{ device, pool ? "rpool", ashift ? "12" }:
{
  disko.devices = {
    disk.main = {
      type = "disk";
      inherit device;
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "512MiB"; type = "EF00";
            content = { type = "filesystem"; format = "vfat"; mountpoint = "/boot"; };
          };
          zfs = {
            size = "100%";
            content = { type = "zfs"; pool = pool; };
          };
        };
      };
    };

    zpool.${pool} = {
      type = "zpool";
      mode = "single";
      options = {
        ashift = ashift;       # 12 for SSD/NVMe
        autotrim = "on";
      };
      rootFsOptions = {
        atime = "off";
        compression = "zstd";
        xattr = "sa";
        acltype = "posixacl";
        mountpoint = "none";   # datasets set mountpoints
      };
      datasets = {
        "${pool}/root" = { type = "zfs_fs"; mountpoint = "/"; options = { canmount = "noauto"; }; };
        "${pool}/nix"  = { type = "zfs_fs"; mountpoint = "/nix"; };
        "${pool}/home" = { type = "zfs_fs"; mountpoint = "/home"; };
        "${pool}/var_log" = { type = "zfs_fs"; mountpoint = "/var/log"; };
        # Example zvol swap (DISABLED; prefer zram)
        # "${pool}/swap" = { type = "zfs_zvol"; size = "8G"; options = { compression = "zle"; sync = "always"; logbias = "throughput"; }; };
      };
    };
  };
}
