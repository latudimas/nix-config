{ pkgs, ... }:
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;

    # stdlib = ''
    #   # Layout for Python projects
    #   layout_python() {
    #     local python=''${1:-python3}
    #     export VIRTUAL_ENV="$PWD/.direnv/python-venv"
    #
    #     if [[ ! -d $VIRTUAL_ENV ]]; then
    #       $python -m venv "$VIRTUAL_ENV"
    #     fi
    #
    #     source "$VIRTUAL_ENV/bin/activate"
    #   }
    #
    #   # Layout for Node.js projects
    #   layout_node() {
    #     export NODE_PATH="$PWD/node_modules"
    #     PATH_add node_modules/.bin
    #   }
    #
    #   # Layout for Go projects
    #   layout_go() {
    #     export GOPATH="$PWD/.direnv/go"
    #     PATH_add "$GOPATH/bin"
    #   }
    # '';
  };
}
