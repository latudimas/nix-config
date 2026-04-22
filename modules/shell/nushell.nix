{ pkgs, lib, ... }:
{
  programs.nushell = {
    enable = true;

    # Environment configuration (env.nu)
    envFile.text = ''
      # Android Studio bundled JDK (for running ./gradlew)
      $env.JAVA_HOME = "/Applications/Android Studio.app/Contents/jbr/Contents/Home"

      # Source nix-darwin environment paths
      $env.PATH = ($env.PATH | split row (char esep)
        | prepend "/opt/homebrew/bin"
        | prepend "/usr/local/bin"
        | prepend "/nix/var/nix/profiles/default/bin"
        | prepend "/run/current-system/sw/bin"
        | prepend $"/etc/profiles/per-user/($env.USER)/bin"
        | prepend $"($env.HOME)/.nix-profile/bin"
        | prepend $"($env.HOME)/.local/bin"
        | prepend "/Users/dims/.opencode/bin"
        | uniq
      )
    '';

    # Nushell configuration (config.nu)
    configFile.text = ''
      $env.config = {
        show_banner: false
        edit_mode: vi

        history: {
          max_size: 10000
          sync_on_enter: true
          file_format: "sqlite"
        }

        completions: {
          case_sensitive: false
          quick: true
          partial: true
          algorithm: "fuzzy"
        }

        keybindings: [
          {
            name: history_search_up
            modifier: none
            keycode: up
            mode: [emacs, vi_normal, vi_insert]
            event: { send: SearchHistory }
          }
          {
            name: history_search_down
            modifier: none
            keycode: down
            mode: [emacs, vi_normal, vi_insert]
            event: { send: NextHistory }
          }
        ]
      }

      # mkcd: create directory and cd into it
      def --env mkcd [dir: string] {
        mkdir $dir
        cd $dir
      }

      # Welcome message
      def get_greeting [] {
        let hour = (date now | format date "%H" | into int)
        if $hour < 12 {
          "Good morning"
        } else if $hour < 18 {
          "Good afternoon"
        } else {
          "Good evening"
        }
      }

      def print_welcome [] {
        let greeting = (get_greeting)
        let message = $"($greeting), ($env.USER)! 👻"
        let box_width = 36
        let border = ("─" | fill -c "─" -w $box_width)
        let msg_len = ($message | str length)
        let total_pad = $box_width - $msg_len
        let left_pad = ($total_pad // 2)
        let right_pad = ($total_pad - $left_pad)
        let left_spaces = (" " | fill -c " " -w $left_pad)
        let right_spaces = (" " | fill -c " " -w $right_pad)

        print ""
        print $"╭($border)╮"
        print $"│($left_spaces)($message)($right_spaces) │"
        print $"╰($border)╯"
      }

      print_welcome
    '';

    # Shell aliases
    shellAliases = {
      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";

      # List directories (use default nushell)
      # ls = "eza";
      # ll = "eza -l --icons";
      # la = "eza -la --icons";
      # lt = "eza -T";

      # Git shortcuts
      # ga = "git add";
      # gaa = "git add --all";
      # gs = "git status";
      # gc = "git commit -v";
      # gcam = "git commit -a -m";
      # gco = "git checkout";
      # gcb = "git checkout -b";
      # gf = "git fetch";
      # gp = "git push";
      # gl = "git pull";

      # System
      # cat = "bat";
      # vim = "nvim";

      # Nix shortcuts
      nb = "nix build";
      ns = "nix shell";
      nd = "nix develop";
      nf = "nix flake";

      # Darwin shortcuts
      drf = "darwin-rebuild switch --flake";
    };
  };

  # nix-your-shell: replaces zsh-nix-shell plugin
  home.packages = [ pkgs.nix-your-shell ];

  # Starship prompt (works with nushell natively)
  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
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

  # carapace: tab completion engine for nushell
  programs.carapace = {
    enable = true;
    enableNushellIntegration = true;
  };

}
