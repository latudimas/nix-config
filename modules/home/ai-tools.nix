# Aspect: AI command-line tools. (See modules/home/base.nix for how aspects
# work.) Add AI CLIs here; API keys are provided at runtime, never
# committed to this config.
{
  flake.modules.homeManager.aiTools =
    { ... }:
    {
      home.packages = [ ];
    };
}
