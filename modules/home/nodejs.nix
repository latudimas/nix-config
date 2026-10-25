# Aspect: Node.js toolchain. (See modules/home/base.nix for how aspects work.)
# `nodejs_26` pins the major version; pnpm is the package manager.
{
  flake.modules.homeManager.nodejs =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        nodejs_26
        pnpm
      ];
    };
}
