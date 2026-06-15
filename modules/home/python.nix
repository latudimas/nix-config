# Aspect: Python toolchain. Defined but NOT in any profile yet — add
# `hm.python` to a profile in modules/hosts.nix to enable it. With Nix you pick
# interpreter versions explicitly (no pyenv); pipx isolates Python CLI apps.
{
  flake.modules.homeManager.python =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        python312
        pipx
      ];
    };
}
