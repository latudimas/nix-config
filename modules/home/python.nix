# Aspect: Python toolchain. (Defined but not enabled by any profile yet —
# add `hm.python` to a profile in modules/hosts.nix to turn it on.)
{
  flake.modules.homeManager.python =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # Instead of pyenv, specify Python versions you need
        python312
        pipx
      ];
    };
}
