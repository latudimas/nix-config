{ config, pkgs, ... }: {
  home-manager.users.dims = { config, pkgs, ... }: {
    imports = [ ./development.nix ./git.nix ];

    home = {
      username = "dims";
      homeDirectory = "/Users/dims";

      # WARNING: DO NOT CHANGE THIS
      stateVersion = "24.11";
    };

    programs.home-manager.enable = true;
  };
}
