{ pkgs, ... }:
{
  # Install packages
  home.packages = with pkgs; [
    gh # GitHub CLI
    git-lfs # Git Large File Storage
  ];

  # Configure Git
  programs.git = {
    enable = true;
    settings.user.name = "latudimas";
    settings.user.email = "riswandha.ld@gmail.com";

    # Enable useful Git features
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

    # Optional: Add Git aliases
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

  # Configure GitHub CLI
  programs.gh = {
    enable = true;
    settings = {
      # gh config settings
      git_protocol = "ssh";
      editor = "nvim";
      prompt = "enabled";

      # Optional: Configure aliases for gh commands
      aliases = {
        co = "pr checkout";
        pv = "pr view";
      };
    };
  };
}
