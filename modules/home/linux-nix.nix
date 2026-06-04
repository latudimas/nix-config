# Aspect: nix settings for the standalone (Linux) home-manager hosts.
# (See modules/home/base.nix for how aspects work.) allowUnfree is handled by
# the pkgs import in modules/hosts.nix, so it isn't set here.
{
  flake.modules.homeManager.linuxNix =
    { pkgs, ... }:
    {
      # On standalone home-manager we let HM manage the user's nix.conf so the
      # binary cache below takes effect.
      nix.package = pkgs.nix;

      # Personal binary cache — get the key from:
      # https://app.cachix.org/cache/dims-nix
      # Requires dims to be in trusted-users first (run scripts/setup-linux.sh once).
      nix.settings = {
        extra-substituters = [ "https://dims-nix.cachix.org" ];
        extra-trusted-public-keys = [
          "dims-nix.cachix.org-1:42IUG0D/t5x5liUzsGzn0UJDfbJ86eO34cJeDkwqLlk="
        ];
      };
    };
}
