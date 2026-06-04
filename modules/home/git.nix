# Aspect: git + GitHub CLI.
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
        settings.user.name = "latudimas";
        settings.user.email = "riswandha.ld@gmail.com";

        lfs.enable = true;
        ignores = [
          ".DS_Store"
          "*.swp"
          ".direnv"
        ];

        settings = {
          init.defaultBranch = "main";
          pull.rebase = true;
          push.autoSetupRemote = true;
          core.editor = "nvim";
        };

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
          git_protocol = "ssh";
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
