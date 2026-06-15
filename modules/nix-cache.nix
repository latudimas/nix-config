# Aspect: the dims-nix Cachix binary cache — spans all three module classes.
# ============================================================================
# One file owns the substituter URL + public key, registered for darwin,
# nixos, and home-manager. Rotating the key is a one-file edit.
# Get the key from: https://app.cachix.org/cache/dims-nix
let
  substituters = [ "https://dims-nix.cachix.org" ];
  trusted-public-keys = [
    "dims-nix.cachix.org-1:42IUG0D/t5x5liUzsGzn0UJDfbJ86eO34cJeDkwqLlk="
  ];
in
{
  # macOS SYSTEM half — nix-darwin manages the system-wide nix.conf.
  flake.modules.darwin.cache = {
    nix.settings.extra-substituters = substituters;
    nix.settings.extra-trusted-public-keys = trusted-public-keys;
  };

  # NixOS half (WSL) — NixOS manages the system-wide nix.conf.
  flake.modules.nixos.cache = {
    nix.settings.extra-substituters = substituters;
    nix.settings.extra-trusted-public-keys = trusted-public-keys;
  };

  # Standalone (Linux) home-manager half — HM manages the user's nix.conf.
  # Requires `nix.package` to be set (done in modules/home/linux-nix.nix) and
  # dims in trusted-users (run scripts/setup-linux.sh once).
  flake.modules.homeManager.cache = {
    nix.settings = {
      extra-substituters = substituters;
      extra-trusted-public-keys = trusted-public-keys;
    };
  };
}
