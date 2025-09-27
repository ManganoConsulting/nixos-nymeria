{
  config,
  pkgs,
  ...
}: {
  users.users.matthew = {
    isNormalUser = true;
    description = "Matthew";
    extraGroups = ["networkmanager" "wheel" "libvirtd"];
    shell = pkgs.zsh;
    packages = with pkgs; [];
  };

  services.getty.autologinUser = "matthew";
}
