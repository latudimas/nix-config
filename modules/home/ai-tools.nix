# Aspect: AI command-line tools. (See modules/home/base.nix for how aspects
# work.) Add CLIs like gemini-cli here; API keys are provided at runtime, never
# committed to this config.
{
  flake.modules.homeManager.aiTools =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        gemini-cli
      ];
    };
}
