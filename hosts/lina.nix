{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ ./hardware-configuration.nix ];

  zramSwap.enable = true;
  security.sudo.wheelNeedsPassword = false;

  networking.hostName = "lina";

  services.openssh.enable = true;
  services.qemuGuest.enable = true;

  systemd.network.enable = true;

  systemd.network.networks."10-nat-lan" = {
    matchConfig.Name = "nat-lan";
    linkConfig.RequiredForOnline = true;
    DHCP = "yes";
  };

  systemd.network.links."10-nat-lan" = {
    matchConfig.MACAddress = "bc:24:11:e3:85:1e";
    linkConfig.Name = "nat-lan";
  };

  systemd.network.networks."10-wan" = {
    matchConfig.Name = "wan";
    linkConfig.RequiredForOnline = true;
    networkConfig.Address = [ "2001:bc8:38ee:100:500::1/64" ];
  };

  systemd.network.links."10-wan" = {
    matchConfig.MACAddress = "bc:24:11:01:14:9e";
    linkConfig.Name = "wan";
  };

  users.mutableUsers = false;
  users.users.root = {
    hashedPassword = "$y$j9T$/8iLMIzRTtbOFcYoZVMX50$OzP/C.4ytzi/WtQjKEp2JUw6bQxcCbT4xoedtLgDEJ0";
    openssh.authorizedKeys.keyFiles = [
      ./raito.keys
      ./janik.keys
    ];
  };
}
