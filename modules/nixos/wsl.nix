# modules/nixos/wsl.nix — the NixOS-on-WSL *system* aspect.
# ============================================================================
# Third module class after homeManager and darwin: this registers a reusable
# NixOS module under `flake.modules.nixos.wsl`. It assumes the host also
# imports `inputs.nixos-wsl.nixosModules.default` (done in modules/hosts.nix),
# which provides the `wsl.*` options and the WSL boot/init plumbing.
{
  flake.modules.nixos.wsl =
    { pkgs, ... }:
    {
      wsl.enable = true;
      wsl.defaultUser = "dims"; # the user WSL drops you into

      nixpkgs.hostPlatform = "x86_64-linux";
      nixpkgs.config.allowUnfree = true;

      # Enable flakes + the new `nix` CLI (needed for `nixos-rebuild --flake`).
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      # Users allowed to configure binary caches (see modules/nix-cache.nix).
      nix.settings.trusted-users = [
        "root"
        "dims"
      ];

      # zsh as login shell: NixOS requires the system half (programs.zsh) for
      # /etc/zshenv etc.; home-manager (hm.zsh) owns the user config.
      programs.zsh.enable = true;
      users.users.dims = {
        isNormalUser = true;
        shell = pkgs.zsh;
      };

      # The NixOS release this machine was first installed with.
      # WARNING: DO NOT CHANGE after first install.
      system.stateVersion = "25.11";
    };
}
