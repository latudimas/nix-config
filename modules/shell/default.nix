{ pkgs, ... }:
{
  imports = [
    ./zsh.nix
    # ./nushell.nix
    ./tmux.nix
    ./direnv.nix    # Adding direnv configuration
    ./ai-tools.nix
    ./helix.nix
  ];
}
