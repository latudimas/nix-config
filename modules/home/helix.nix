# Aspect: Helix editor. (See modules/home/base.nix for how aspects work.)
# A modal terminal editor; `enable = true` installs it and writes its config.
{
  flake.modules.homeManager.helix = {
    programs.helix.enable = true;
  };
}
