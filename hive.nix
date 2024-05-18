let 
  sources = import ./npins;
  nixos-dns = import sources.nixos-dns;
in
{
  meta = {
    inherit (sources) nixpkgs;
  };

  defaults = { pkgs, config, ... }: {
    imports = [
      (nixos-dns.nixosModules.default)
    ];
    networking.domain = "lineaire.moe";
    networking.domains.subDomains."${config.networking.fqdn}" = { };
  };

  lina = { name, nodes, ... }: {
    deployment.targetHost = "lina.lineaire.moe";
    imports = [
      ./hosts/lina.nix
    ];
  };
}
