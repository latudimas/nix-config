{ pkgs, ... }:
{
  home.packages = with pkgs; [
    coreutils
    fastfetch
    btop
    bat
    eza
    jq
    fd
    fzf
    ripgrep
  ];

  programs.zoxide = {
    enable = true;
    
    # setup shell integration in nix way
    # commonly we need to use : eval "$(zoxide init zsh)" 
    enableZshIntegration = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableNushellIntegration = true;
  };
}
