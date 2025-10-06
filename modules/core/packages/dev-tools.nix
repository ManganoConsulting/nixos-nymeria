{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    gcc
    gnumake
    bcc
    tmux
    zsh
    fish
    fzf
    ripgrep
    luarocks
    lua-language-server
    nodePackages.prettier
    nodePackages.eslint_d
    kustomize
    yq-go
    jq
    cilium-cli
    flux
    virt-manager
    # Cloud CLI tools
    google-cloud-sdk
    awscli2
    # Python development environment
    python312
    python312Packages.pip
    python312Packages.virtualenv
    python312Packages.setuptools
    # Wave terminal
    waveterm
  ];
}
