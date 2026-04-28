{ pkgs, ... }:
let
  devenvDirenvrc = pkgs.runCommand "devenv-direnvrc" { } ''
    ${pkgs.devenv}/bin/devenv direnvrc > $out
  '';
in
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
    # enableNushellIntegration = true;

    stdlib = ''
      source ${devenvDirenvrc}

      # Restores the user's login shell after nix/devenv environments
      # override $SHELL with bash (comes from Nix stdenv).
      # Usage: call restore_shell in .envrc after use devenv / use flake
      restore_shell() {
        if [[ "$OSTYPE" == "darwin"* ]]; then
          export SHELL="$(dscl . -read /Users/$USER UserShell 2>/dev/null | awk '{print $2}')"
        else
          export SHELL="$(getent passwd $USER | cut -d: -f7)"
        fi
      }
    '';
  };
}
