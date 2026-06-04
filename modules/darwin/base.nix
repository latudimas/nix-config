# modules/darwin/base.nix — the macOS *system* aspect.
# ============================================================================
# DENDRITIC MECHANIC: this file is a flake-parts module. Assigning to
# `flake.modules.darwin.base` publishes a reusable nix-darwin module named
# "base" under the "darwin" class; modules/hosts.nix pulls it in via
# `config.flake.modules.darwin.base`. (This was hosts/smol/system.nix in the
# modular branch.) Options reference: https://daiderd.com/nix-darwin/manual/
{
  flake.modules.darwin.base =
    { pkgs, ... }:
    {
      # nix-darwin defaults baseline; bump only when release notes say so.
      system.stateVersion = 5;

      # Must match the host's `system` in modules/hosts.nix.
      nixpkgs.hostPlatform = "aarch64-darwin";

      # Permit packages with non-free licenses.
      nixpkgs.config.allowUnfree = true;

      # Enable flakes + the new `nix` CLI (needed for `darwin-rebuild --flake`).
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      # Users allowed to configure binary caches (for devenv/cachix below).
      nix.settings.trusted-users = [
        "root"
        "dims"
      ];

      # Personal binary cache — get the key from:
      # https://app.cachix.org/cache/dims-nix
      nix.settings.extra-substituters = [ "https://dims-nix.cachix.org" ];
      nix.settings.extra-trusted-public-keys = [
        "dims-nix.cachix.org-1:42IUG0D/t5x5liUzsGzn0UJDfbJ86eO34cJeDkwqLlk="
      ];

      # Make zsh a known login shell and dims' default shell.
      environment.shells = [ pkgs.zsh ];
      users.users.dims.shell = pkgs.zsh;
      users.users.dims.home = "/Users/dims";
    };
}
