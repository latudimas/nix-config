# Aspect: Java toolchain. (See modules/home/base.nix for how aspects work.)
# `programs.java` installs the JDK *and* exports JAVA_HOME pointing at it,
# which build tools (gradle, maven, IDEs) need to find the SDK.
{
  flake.modules.homeManager.java =
    { pkgs, ... }:
    {
      programs.java = {
        enable = true;
        package = pkgs.jdk21; # pin the major version, like nodejs_24
      };
    };
}
