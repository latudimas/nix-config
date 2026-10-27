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
        neovim # terminal editor; config lives in ~/.config/nvim
        age # file encryption (age-keygen makes your key pair)
        sops # edit encrypted secrets files; uses age keys
      ];

      # One age key location on every OS (macOS default is ~/Library/Application Support).
      home.sessionVariables = {
        SOPS_AGE_KEY_FILE = "$HOME/.config/sops/age/keys.txt";
        # `sops edit` opens decrypted plaintext; keep nvim from saving it to
        # swap (-n), shada/registers (-i NONE), or persistent undo files.
        SOPS_EDITOR = "nvim -n -i NONE -c 'set noundofile'";
      };

      # zoxide = a smarter `cd` that learns your most-used directories (`z foo`).
      # Setting integrations here is the Nix-native way of `eval "$(zoxide init zsh)"`.
      programs.zoxide = {
        enable = true;
        enableZshIntegration = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
      };
    };
}
