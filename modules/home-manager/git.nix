{ config, ... }: {
  programs.git = {
    enable = true;
    userName = "latudimas";
    userEmail = "riswandha.ld@gmail.com";

    aliases = {
      ga = "add";
      gaa = "add --all";
      gc = "commit -v";
      gcam = "commit -a -m";
      gco = "checkout";
      gcb = "checkout -b";
      gf = "fetch";
      gp = "push";
      gl = "pull";
    };
  };
}
