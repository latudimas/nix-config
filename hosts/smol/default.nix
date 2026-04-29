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

      # Mac Mini: Add Homebrew PostgreSQL 18 to PATH
      home.sessionPath = [ "/opt/homebrew/opt/postgresql@18/bin" ];
    };
  };
}
