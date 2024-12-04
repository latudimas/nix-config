{ pkgs, ... }: {
  home.packages = with pkgs; [

    # CLI tools
    ripgrep
    fd
    jq
    fzf
    bat
    fastfetch
    eza
    zoxide

  ];
}
