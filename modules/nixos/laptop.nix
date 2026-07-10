# modules/nixos/laptop.nix — the dims-laptop *system* aspect (bare metal).
# ============================================================================
# Sibling of modules/nixos/wsl.nix: registers `flake.modules.nixos.laptop`.
# Everything WSL gives us for free (boot, network, audio, session) is spelled
# out here instead. The disk layout lives in laptop-disko.nix; the machine-
# generated initrd/microcode bits live in laptop-hardware.nix.
{
  flake.modules.nixos.laptop =
    { pkgs, ... }:
    {
      networking.hostName = "dims-laptop";

      # UEFI boot via systemd-boot (the ESP is defined in laptop-disko.nix).
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      networking.networkmanager.enable = true;
      hardware.bluetooth.enable = true;

      time.timeZone = "Asia/Jakarta";
      i18n.defaultLocale = "en_US.UTF-8";

      # Hyprland — SYSTEM half only: session registration, XDG portals, polkit.
      # The per-user hyprland.conf should become a home-manager aspect
      # (modules/home/hyprland.nix) once the config grows beyond defaults.
      programs.hyprland.enable = true;
      security.polkit.enable = true;

      # tuigreet: minimal TTY-style greeter that launches Hyprland on login.
      services.greetd = {
        enable = true;
        settings.default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
          user = "greeter";
        };
      };

      # Audio: pipewire (wireplumber session manager is the default).
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
      };

      # NixOS half of the kitty aspect: hm.kitty configures the terminal and
      # names this font; the system installs it (same split as the darwin
      # half in modules/home/kitty.nix).
      fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

      # Wayland survival kit for the first boot. The default hyprland.conf
      # binds kitty (installed by hm.kitty) and wofi. Migrate these into a
      # home-manager hyprland aspect later.
      environment.systemPackages = with pkgs; [
        wofi # app launcher ($menu in the default hyprland.conf)
        brightnessctl # backlight control for media keys
        wl-clipboard
        grim
        slurp # screenshots: grim + slurp
      ];

      # Monthly whole-filesystem checksum pass (btrfs bit-rot detection).
      services.btrfs.autoScrub = {
        enable = true;
        interval = "monthly";
      };

      nixpkgs.hostPlatform = "x86_64-linux";
      nixpkgs.config.allowUnfree = true;

      # Enable flakes + the new `nix` CLI (needed for `nixos-rebuild --flake`).
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      # Users allowed to configure binary caches (see modules/nix-cache.nix).
      nix.settings.trusted-users = [
        "root"
        "dims"
      ];

      # zsh as login shell: NixOS requires the system half (programs.zsh) for
      # /etc/zshenv etc.; home-manager (hm.zsh) owns the user config.
      programs.zsh.enable = true;
      users.users.dims = {
        isNormalUser = true;
        shell = pkgs.zsh;
        extraGroups = [
          "wheel" # sudo
          "networkmanager" # manage wifi without root
        ];
      };

      # The NixOS release this machine was first installed with.
      # WARNING: DO NOT CHANGE after first install.
      system.stateVersion = "26.11";
    };
}
