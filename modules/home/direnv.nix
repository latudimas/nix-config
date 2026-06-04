# Aspect: direnv + devenv integration. (See modules/home/base.nix for how
# aspects work.) direnv auto-loads a project's environment when you cd into it.
{
  flake.modules.homeManager.direnv =
    { pkgs, ... }:
    let
      # Build devenv's direnv helpers ONCE into the Nix store, so each project's
      # `.envrc` can `use devenv` without rebuilding them every time.
      devenvDirenvrc = pkgs.runCommand "devenv-direnvrc" { } ''
        ${pkgs.devenv}/bin/devenv direnvrc > $out
      '';
    in
    {
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true; # faster, caching Nix integration
        enableZshIntegration = true;

        # `stdlib` is appended to direnv's standard library, making the helpers
        # below available inside every `.envrc`.
        stdlib = ''
          source ${devenvDirenvrc}

          # Restores the user's login shell after nix/devenv environments override
          # $SHELL with bash (which comes from the Nix stdenv).
          # Usage: call restore_shell in .envrc after `use devenv` / `use flake`.
          restore_shell() {
            if [[ "$OSTYPE" == "darwin"* ]]; then
              export SHELL="$(dscl . -read /Users/$USER UserShell 2>/dev/null | awk '{print $2}')"
            else
              export SHELL="$(getent passwd $USER | cut -d: -f7)"
            fi
          }
        '';
      };
    };
}
