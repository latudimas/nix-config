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

      # Sole source of truth for the platform (hosts.nix passes no `system`).
      nixpkgs.hostPlatform = "aarch64-darwin";

      # Permit packages with non-free licenses.
      nixpkgs.config.allowUnfree = true;

      # Enable flakes + the new `nix` CLI (needed for `darwin-rebuild --flake`).
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      # Users allowed to configure binary caches (see modules/nix-cache.nix).
      nix.settings.trusted-users = [
        "root"
        "dims"
      ];

      # Make zsh a known login shell and dims' default shell.
      environment.shells = [ pkgs.zsh ];
      users.users.dims.shell = pkgs.zsh;
      users.users.dims.home = "/Users/dims";
    };
}
