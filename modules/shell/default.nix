{ pkgs, ... }:
{
  imports = [
    ./zsh.nix
    # ./nushell.nix  # uncomment to switch back to nushell
    ./tmux.nix
    ./direnv.nix    # Adding direnv configuration
    ./ai-tools.nix
    ./helix.nix
  ];
}
