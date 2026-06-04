# Aspect: Node.js toolchain.
{
  flake.modules.homeManager.nodejs =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        nodejs_24
        nodePackages.pnpm
      ];
    };
}
