{ pkgs, ... }:
{
  imports = [
    ./zsh.nix
    ./tmux.nix
    ./direnv.nix    # Adding direnv configuration
    ./ai-tools.nix
    ./helix.nix
  ];
}
