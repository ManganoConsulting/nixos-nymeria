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
    omnictl
    ceph
    kubelogin-oidc
    kubernetes-helm
    bat
    argocd
  ];
}
