# modules/home/base.nix — the home-manager base aspect (username, state version).
# ============================================================================
# HOW A DENDRITIC ASPECT WORKS  (read this once — every file in modules/home
# follows the same shape):
#
#   Every file here is a flake-parts module. Assigning to
#   `flake.modules.homeManager.<name>` REGISTERS a reusable home-manager module
#   under the "homeManager" class. Nothing is activated by registering it —
#   modules/hosts.nix decides which named modules each machine turns on (its
#   "profile").
#
#   Recipe to add a feature:
#     1. make a file that sets `flake.modules.homeManager.<yourname> = { ... };`
#     2. add `hm.<yourname>` to a profile in modules/hosts.nix.
{
  flake.modules.homeManager.base = {
    # Let home-manager manage itself (gives you the `home-manager` command).
    programs.home-manager.enable = true;

    home.username = "dims";

    # The home-manager release this profile targets.
    # WARNING: DO NOT CHANGE after first install.
    home.stateVersion = "24.11";
  };
}
