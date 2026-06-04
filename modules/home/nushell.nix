# Aspect: nushell (a structured-data shell). Defined but NOT in any profile —
# swap `hm.zsh` for `hm.nushell` in a profile in modules/hosts.nix to use it.
# `envFile.text` becomes env.nu and `configFile.text` becomes config.nu.
{
  flake.modules.homeManager.nushell =
    { pkgs, lib, ... }:
    {
      programs.nushell = {
        enable = true;

        # env.nu — environment setup (runs first).
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

        # config.nu — interactive settings, keybindings, custom commands.
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

        # Aliases (git/ls ones are commented out so nushell's built-ins shine).
        shellAliases = {
          ".." = "cd ..";
          "..." = "cd ../..";
          nb = "nix build";
          ns = "nix shell";
          nd = "nix develop";
          nf = "nix flake";
          drf = "darwin-rebuild switch --flake";
        };
      };

      # nix-your-shell: drops you back into nushell after `nix develop`/`nix shell`
      # (the nushell equivalent of the zsh-nix-shell plugin).
      home.packages = [ pkgs.nix-your-shell ];

      # starship prompt — nushell integration enabled.
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

      # carapace — completions for many CLIs inside nushell.
      programs.carapace = {
        enable = true;
        enableNushellIntegration = true;
      };
    };
}
