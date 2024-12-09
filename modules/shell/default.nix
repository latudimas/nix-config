{ pkgs, ... }:
{
  imports = [
    ./zsh.nix
    ./tmux.nix
    ./aliases.nix
    # ./direnv.nix    # Adding direnv configuration
  ];
}
