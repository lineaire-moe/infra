let 
  sources = import ./npins;
in
{
  meta = {
    inherit (sources) nixpkgs;
  };

  defaults = { pkgs, ... }: { };

  lina = { name, nodes, ... }: {
    deployment.targetHost = "lina.lineaire.moe";
    imports = [
      ./hosts/lina.nix
    ];
  };
}
