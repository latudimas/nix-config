# Aspect: home-manager base (username / state version).
{
  flake.modules.homeManager.base = {
    programs.home-manager.enable = true;

    home.username = "dims";

    # WARNING: DO NOT CHANGE THIS
    home.stateVersion = "24.11";
  };
}
