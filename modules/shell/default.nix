{ pkgs, ... }:
{
  imports = [
    ./zsh.nix
    ./tmux.nix
    # ./direnv.nix    # Adding direnv configuration
  ];
}
