# Aspect: direnv + nix-direnv. (See modules/home/base.nix for how aspects
# work.) direnv auto-loads a project's environment when you cd into it; each
# project's `.envrc` uses `use flake` to enter its flake.nix devShell.
{
  flake.modules.homeManager.direnv = {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true; # faster, caching Nix integration
      enableZshIntegration = true;

      # `stdlib` is appended to direnv's standard library, making the helpers
      # below available inside every `.envrc`.
      stdlib = ''
        # Restores the user's login shell after nix environments override
        # $SHELL with bash (which comes from the Nix stdenv).
        # Usage: call restore_shell in .envrc after `use flake`.
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
