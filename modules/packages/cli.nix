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
    lazygit
    mkcert #for local development certificate
    rar # rar archives utilities

    devenv #development environment for local dev setup
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
