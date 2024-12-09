{ pkgs, ... }:
{
  imports = [
    ./cli.nix
    ./git.nix
  ];
}
