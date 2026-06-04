# Aspect: git + GitHub CLI. (See modules/home/base.nix for how aspects work.)
# home-manager renders your git config from `settings`, so it's declarative and
# identical on every machine — no hand-edited ~/.gitconfig.
{
  flake.modules.homeManager.git =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        gh # GitHub CLI
        git-lfs # Git Large File Storage
      ];

      programs.git = {
        enable = true;

        # Identity stamped on your commits.
        settings.user.name = "latudimas";
        settings.user.email = "riswandha.ld@gmail.com";

        lfs.enable = true; # track large binaries via git-lfs

        # A global gitignore applied in every repo.
        ignores = [
          ".DS_Store"
          "*.swp"
          ".direnv"
        ];

        settings = {
          init.defaultBranch = "main";
          pull.rebase = true; # rebase instead of merge on `git pull`
          push.autoSetupRemote = true; # first push auto-creates the upstream branch
          core.editor = "nvim";
        };

        # Shorthands: `git st`, `git co`, `git visual`, ...
        settings.alias = {
          st = "status";
          co = "checkout";
          br = "branch";
          ci = "commit";
          unstage = "reset HEAD --";
          last = "log -1 HEAD";
          visual = "log --graph --decorate --oneline";
        };
      };

      programs.gh = {
        enable = true;
        settings = {
          git_protocol = "ssh"; # clone/push over SSH
          editor = "nvim";
          prompt = "enabled";
          aliases = {
            co = "pr checkout";
            pv = "pr view";
          };
        };
      };
    };
}
