{ pkgs, colmena, nixos-dns }: let
  generate = nixos-dns.utils.generate pkgs;
in generate.zoneFiles {
  nixosConfigurations = (import "${colmena}/src/nix/hive/eval.nix" {
    rawHive = (import ./hive.nix);
  }).nodes;
  extraConfig = {
    defaultTTL = 120;
    zones = {
      "lineaire.moe" = {
        "" = {
          caa.data = {
            flags = 0;
            tag = "issue";
            value = "letsencrypt.org";
          };
          ns.data = [
            "ns-123-c.gandi.net"
            "ns-64-b.gandi.net"
            "ns-22-a.gandi.net"
          ];
        };
      };
    };
  };
}
