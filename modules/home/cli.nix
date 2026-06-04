# Aspect: everyday CLI tools.
{
  flake.modules.homeManager.cli =
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
        mkcert # for local development certificate
        rar # rar archives utilities
        devenv # development environment for local dev setup
      ];

      programs.zoxide = {
        enable = true;
        enableZshIntegration = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableNushellIntegration = true;
      };
    };
}
