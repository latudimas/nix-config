# Aspect: nix settings for the standalone (Linux) home-manager hosts.
# (See modules/home/base.nix for how aspects work.) allowUnfree is handled by
# the pkgs import in modules/hosts.nix, so it isn't set here.
{
  flake.modules.homeManager.linuxNix =
    { pkgs, ... }:
    {
      # On standalone home-manager we let HM manage the user's nix.conf so the
      # binary cache (modules/nix-cache.nix, selected via hm.cache) takes effect.
      nix.package = pkgs.nix;
    };
}
