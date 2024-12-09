{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Instead of pyenv, specify Python versions you need
    python312
    pipx
  ];
}
