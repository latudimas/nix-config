{ pkgs, ... }:
{
  imports = [
    # ./zsh.nix     # Commented out: replaced by nushell
    ./nushell.nix
    ./tmux.nix
    ./direnv.nix    # Adding direnv configuration
    ./ai-tools.nix
    ./helix.nix
  ];
}
