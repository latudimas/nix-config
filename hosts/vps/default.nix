{ pkgs, ... }:
{
  home.packages = with pkgs; [
    neovim
    zsh
    ripgrep
    git
    curl
  ];
  home.stateVersion = "24.11";
  home.homeDirectory = "/home/dims";
}
