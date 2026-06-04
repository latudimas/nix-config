# Aspect: nushell (alternative shell). Defined but not enabled by any profile —
# swap `hm.zsh` for `hm.nushell` in a profile in modules/hosts.nix to use it.
{
  flake.modules.homeManager.nushell =
    { pkgs, lib, ... }:
    {
      programs.nushell = {
        enable = true;

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
        '';

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

      home.packages = [ pkgs.nix-your-shell ];

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

      programs.carapace = {
        enable = true;
        enableNushellIntegration = true;
      };
    };
}
