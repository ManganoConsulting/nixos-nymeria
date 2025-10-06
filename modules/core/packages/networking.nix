{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    dig
    iperf3
    nmap
    tcpdump
    traceroute
    mtr
    keepalived
    iftop
    ethtool
    openvswitch
    wireshark-cli
    wireguard-tools
    mozillavpn
  ];
}
