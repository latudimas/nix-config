{ pkgs, ... }:
{
  imports = [
    ./system.nix
  ];
}

#--------- before update -------------

# { config, pkgs, ... }: {
#
#   # import home manager modules
#   imports = [ ../../modules/home-manager/default.nix ];
#
#   # Enable necessary system services
#   services.nix-daemon.enable = true;
#
#   # System-wide environment stettings
#   environment = {
#     # System-wide packages
#     systemPackages = with pkgs; [ wget ];
#
#     # Shell Configuration
#     shells = with pkgs; [ bash zsh ];
#     loginShell = pkgs.zsh;
#
#     pathsToLink = [ "/Applications" ];
#   };
#
#   nix.settings = { experimental-features = [ "nix-command" "flakes" ]; };
#
#   # System state version
#   system.stateVersion = 5;
#
#   # Set git commint hash for darwin version
#   system.configurationRevision = null;
#
#   # Allow unfree packages
#   nixpkgs.config.allowUnfree = true;
#
#   # The platform the config will be used on
#   nixpkgs.hostPlatform = "aarch64-darwin";
# }
