{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    kitty
    ghostty
    zoxide
    direnv
    nix-direnv
    usbutils
    pciutils
    bolt
    yazi
    minicom
    tftp-hpa
    kubectl
    talosctl
    # omnictl  # Temporarily disabled due to network timeouts
    # ceph  # Temporarily disabled due to build issue in unstable
    kubelogin-oidc
    kubernetes-helm
    bat
    argocd
  ];
}
