{ pkgs, ... }:
{
  home.shellAliases = {
    # Navigation
    ".." = "cd ..";
    "..." = "cd ../..";

    # List directories
    ls = "eza"; # Replace ls with eza
    ll = "eza -l --icons"; # List in long format
    la = "eza -la"; # List all files
    lt = "eza -T"; # Tree view

    # Git shortcuts -- Claude generated
    # g = "git";
    # gs = "git status";
    # ga = "git add";
    # gc = "git commit";
    # gp = "git push";
    # gl = "git pull";

    # Git shortcuts -- Manually generated
    ga = "add";
    gaa = "add --all";
    gc = "commit -v";
    gcam = "commit -a -m";
    gco = "checkout";
    gcb = "checkout -b";
    gf = "fetch";
    gp = "push";
    gl = "pull";

    # System
    # cat = "bat";              # Replace cat with bat
    # vim = "nvim";             # Use neovim

    # Nix shortcuts
    nb = "nix build";
    ns = "nix shell";
    nd = "nix develop";
    nf = "nix flake";

    # Darwin shortcuts
    drsf = "darwin-rebuild switch --flake";

    # Development
    # d = "docker";
    # dc = "docker-compose";
    # k = "kubectl";

    # Custom functions
    mkcd = "mkdir -p \"$1\" && cd \"$1\"";
  };
}
