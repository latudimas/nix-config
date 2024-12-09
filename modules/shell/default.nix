{ pkgs, ... }:
{
  imports = [
    ./zsh.nix
    ./tmux.nix
    ./aliases.nix # currently not used, using shellAliases on zsh.nix
    # ./direnv.nix    # Adding direnv configuration
  ];
}
