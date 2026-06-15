# Aspect: yazi terminal file manager. (See modules/home/base.nix for how
# aspects work.) Provides the `y` command: opens yazi and, on quit, cds into
# the last selected directory.
{
  flake.modules.homeManager.yazi = {
    programs.yazi = {
      enable = true;
      shellWrapperName = "y"; # defaults to "yy" on home.stateVersion < 26.05
      enableZshIntegration = true;
      enableNushellIntegration = true;
    };
  };
}
