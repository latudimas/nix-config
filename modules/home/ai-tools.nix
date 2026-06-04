# Aspect: AI CLI tools.
{
  flake.modules.homeManager.aiTools =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        gemini-cli
      ];
    };
}
