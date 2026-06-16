# Aspect: everyday command-line tools. (See modules/home/base.nix for how
# aspects work.) `with pkgs;` lets us write bare names instead of pkgs.<name>.
{
  flake.modules.homeManager.cli =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        coreutils
        fastfetch # system info banner
        btop # process/resource monitor
        bat # `cat` with syntax highlighting
        eza # modern `ls`
        jq # JSON processor
        fd # friendly `find`
        fzf # fuzzy finder
        ripgrep # fast `grep` (rg)
        tree-sitter # parser generator tool
        lazygit # terminal git UI
        mkcert # local development certificates
        rar # rar archive utilities
        devenv # per-project development environments
      ];

      # zoxide = a smarter `cd` that learns your most-used directories (`z foo`).
      # Setting integrations here is the Nix-native way of `eval "$(zoxide init zsh)"`.
      programs.zoxide = {
        enable = true;
        enableZshIntegration = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableNushellIntegration = true;
      };
    };
}
