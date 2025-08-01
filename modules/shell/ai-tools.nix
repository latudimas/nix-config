{ pkgs, ... }:
{
  # install from nixpkgs
  home.packages = with pkgs; [
    claude-code
    opencode
    gemini-cli
  ];

  # Environment variables for Claude Code
  home.sessionVariables = {
    # Optional: Set Claude Code specific configurations
    # CLAUDE_API_KEY will need to be set separately for authentication
  };

}
