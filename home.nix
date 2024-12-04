{ pkgs, ... }:
{
  programs.home-manager.enable = true;

  home = {
    username = "dims";
    homeDirectory = "/Users/dims";
    # homeDirectory = lib.mkForce "/Users/dims";
    stateVersion = "24.11";

    # Installed packages
    packages = with pkgs; [

      # CLI tools
      coreutils # GNU coreutils

      fastfetch # alt to
      btop # alt to htop
      bat # alt to cat
      eza # alt to ls
      zoxide # alt to cd

      jq # json parser
      fd
      fzf
      ripgrep

      # LSP and formatter
      nixfmt-rfc-style # nix formatter

    ];

  };
}
