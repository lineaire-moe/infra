let
  pins = (import ./npins);
in
{
  pkgs ? import pins.nixpkgs {},
  colmena ? pins.colmena,
  nixos-dns ? import pins.nixos-dns
}:
{
  shell = pkgs.mkShell {
    buildInputs = [
      pkgs.colmena
      pkgs.npins
      pkgs.gitFull
      (pkgs.octodns.withProviders (ps: with pkgs.octodns-providers; [ bind gandi ]))
    ];
  };
  dns = import ./dns.nix { inherit pkgs colmena nixos-dns; };
}
