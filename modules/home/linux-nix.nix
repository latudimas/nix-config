# Aspect: nix settings for the standalone (Linux) home-manager hosts.
# allowUnfree is handled by the pkgs import in modules/hosts.nix.
{
  flake.modules.homeManager.linuxNix =
    { pkgs, ... }:
    {
      nix.package = pkgs.nix;

      # Binary cache — get public key from: https://app.cachix.org/cache/dims-nix
      # Requires dims to be in trusted-users first (run scripts/setup-linux.sh once)
      nix.settings = {
        extra-substituters = [ "https://dims-nix.cachix.org" ];
        extra-trusted-public-keys = [
          "dims-nix.cachix.org-1:42IUG0D/t5x5liUzsGzn0UJDfbJ86eO34cJeDkwqLlk="
        ];
      };
    };
}
