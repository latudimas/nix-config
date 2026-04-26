{ ... }:
{
  imports = [ ./system.nix ];

  users.users.dims.home = "/Users/dims";

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    users.dims = {
      imports = [ ../../home/dims.nix ];
      home.homeDirectory = "/Users/dims";
    };
  };
}
