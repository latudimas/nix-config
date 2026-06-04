# Aspect: zsh + starship prompt.
{
  flake.modules.homeManager.zsh =
    { pkgs, lib, ... }:
    {
      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;

        initContent = ''
          # ======================================
          # Enable Vi mode
          # ======================================
          bindkey -v

          # ======================================
          # Better history searching with arrow keys
          # ======================================
          autoload -U up-line-or-beginning-search
          autoload -U down-line-or-beginning-search
          zle -N up-line-or-beginning-search
          zle -N down-line-or-beginning-search
          bindkey "^[[A" up-line-or-beginning-search
          bindkey "^[[B" down-line-or-beginning-search

          # ======================================
          # Additional zsh setting
          # ======================================
          setopt EXTENDED_HISTORY     # Add timestamps to history
          setopt HIST_IGNORE_ALL_DUPS # Ignore duplicates in history
          setopt HIST_FIND_NO_DUPS   # Don't display duplicates when searching
          setopt HIST_SAVE_NO_DUPS   # Don't save duplicates
          setopt SHARE_HISTORY       # Share history between sessions

          # ======================================
          # CLI tools extra setup
          # ======================================
          source <(fzf --zsh) #fzf

          #opencode
          export PATH=$HOME/.opencode/bin:$PATH

          # ======================================
          # Welcome message function
          # ======================================
          function get_greeting() {
            hour=$(date +%H)
            if [ $hour -lt 12 ]; then
              echo "Good morning"
            elif [ $hour -lt 18 ]; then
              echo "Good afternoon"
            else
              echo "Good evening"
            fi
          }

          function print_welcome() {
            greeting=$(get_greeting)
            message="$greeting, $USER! 👻"

            box_width=40
            box_width_padding=36      # workaround for fixing upper and bottom bracket mismatch length
            message_length=$(echo -n "$message" | wc -c)

            total_padding=$((box_width - message_length - 2))
            left_padding=$((total_padding / 2))
            right_padding=$((total_padding - left_padding ))

            echo ""
            printf "╭%s╮\n" "$(printf "─%.0s" $(seq 1 $box_width_padding))"
            printf "│%*s%s%*s│\n" "$left_padding" "" "$message" "$right_padding" ""
            printf "╰%s╯\n" "$(printf "─%.0s" $(seq 1 $box_width_padding))"
          }

          print_welcome
        '';

        history = {
          size = 10000;
          path = "$HOME/.zsh_history";
          save = 10000;
          ignoreDups = true;
          share = true;
          extended = true;
        };

        plugins = [
          {
            name = "zsh-nix-shell";
            file = "nix-shell.plugin.zsh";
            src = pkgs.fetchFromGitHub {
              owner = "chisui";
              repo = "zsh-nix-shell";
              rev = "v0.7.0";
              sha256 = "149zh2rm59blr2q458a5irkfh82y3dwdich60s9670kl3cl5h2m1";
            };
          }
        ];

        shellAliases = lib.mkForce {
          # Navigation
          ".." = "cd ..";
          "..." = "cd ../..";

          # List directories
          ls = "eza";
          ll = "eza -l --icons";
          la = "eza -la --icons";
          lt = "eza -T";

          # Git shortcuts
          ga = "git add";
          gaa = "git add --all";
          gs = "git status";
          gc = "git commit -v";
          gcam = "git commit -a -m";
          gco = "git checkout";
          gcb = "git checkout -b";
          gf = "git fetch";
          gp = "git push";
          gl = "git pull";

          # System
          cat = "bat";
          vim = "nvim";

          # Nix shortcuts
          nb = "nix build";
          ns = "nix shell";
          nd = "nix develop";
          nf = "nix flake";

          # Darwin shortcuts
          drf = "darwin-rebuild switch --flake";

          # Custom functions
          mkcd = "mkdir -p \"$1\" && cd \"$1\"";
        };
      };

      programs.starship = {
        enable = true;
        settings = {
          add_newline = true;
          character = {
            success_symbol = "[➜](bold green)";
            error_symbol = "[➜](bold red)";
          };
          directory = {
            truncation_length = 8;
            truncate_to_repo = true;
          };
        };
      };
    };
}
