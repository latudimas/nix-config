# Aspect: tmux.
{
  flake.modules.homeManager.tmux =
    { pkgs, ... }:
    {
      programs.tmux = {
        enable = true;
        shell = "${pkgs.zsh}/bin/zsh";
        terminal = "screen-256color";
        escapeTime = 0;
        baseIndex = 1;
        keyMode = "vi";
        customPaneNavigationAndResize = true;
        historyLimit = 10000;

        extraConfig = ''
          # Enable mouse support
          set -g mouse on

          # Extended keys support (for Shift+Enter in Claude Code, OpenCode, etc.)
          set -s extended-keys always
          set -as terminal-features 'xterm*:extkeys'

          # Better colors
          set -ga terminal-overrides ",*256col*:Tc"

          # Vi mode selection and copy
          bind-key -T copy-mode-vi v send-keys -X begin-selection
          bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

          # Split panes using | and -
          bind | split-window -h -c "#{pane_current_path}"
          bind - split-window -v -c "#{pane_current_path}"

          # Pane resize using vim motion
          bind -r h resize-pane -L 5
          bind -r j resize-pane -D 5
          bind -r k resize-pane -U 5
          bind -r l resize-pane -R 5

          # Reload config
          bind r source-file ~/.config/tmux/tmux.conf \; display "Reloaded!"

          # Status bar customization
          set -g status-style bg=default
          set -g status-left "#[fg=blue]#S #[fg=white]| "
          set -g status-right "#[fg=yellow]%H:%M #[fg=white]| #[fg=blue]#H"

          # Window status
          setw -g window-status-current-style fg=green,bold
          setw -g window-status-style fg=white
        '';

        plugins = with pkgs; [
          tmuxPlugins.vim-tmux-navigator
        ];
      };
    };
}
