# Aspect: tmux terminal multiplexer. (See modules/home/base.nix for how aspects
# work.) Typed options below become ~/.config/tmux/tmux.conf lines; everything
# else goes in `extraConfig` as raw tmux syntax.
{
  flake.modules.homeManager.tmux =
    { pkgs, ... }:
    {
      programs.tmux = {
        enable = true;
        shell = "${pkgs.zsh}/bin/zsh"; # shell launched in new panes
        terminal = "tmux-256color";
        escapeTime = 0; # no delay after Esc (important for vi mode)
        baseIndex = 1; # number windows/panes from 1, not 0
        keyMode = "vi"; # vi keys in copy mode
        customPaneNavigationAndResize = true;
        historyLimit = 10000;

        extraConfig = ''
          # dynamic renumber
          set -g renumber-windows on

          # Enable mouse support
          set -g mouse on

          # for yazi
          set -g allow-passthrough on

          # Extended keys support (for Shift+Enter in Claude Code, OpenCode, etc.)
          set -s extended-keys always
          set -as terminal-features 'xterm*:extkeys'

          # Better colors
          set -ga terminal-features ",*:RGB"

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

        # Plugins (managed by home-manager, no plugin manager needed).
        plugins = with pkgs; [
          tmuxPlugins.vim-tmux-navigator # seamless ctrl-h/j/k/l between vim & tmux
        ];
      };
    };
}
