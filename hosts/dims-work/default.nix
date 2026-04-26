{ ... }:
{
  imports = [ ../../home/dims.nix ];
  home.homeDirectory = "/home/dims";

  nixpkgs.config.allowUnfree = true;

  # Binary cache — get public key from: https://app.cachix.org/cache/dims-nix
  # Requires dims to be in trusted-users first (run scripts/setup-linux.sh once)
  nix.settings = {
    extra-substituters = [ "https://dims-nix.cachix.org" ];
    extra-trusted-public-keys = [ "dims-nix.cachix.org-1:42IUG0D/t5x5liUzsGzn0UJDfbJ86eO34cJeDkwqLlk=" ];
  };
}
