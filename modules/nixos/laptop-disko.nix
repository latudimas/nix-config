# modules/nixos/laptop-disko.nix — declarative disk layout for dims-laptop.
# ============================================================================
# Disko owns the whole disk story: at INSTALL time it partitions and formats
# the disk; at EVAL time it generates the `fileSystems.*` (and swap) config —
# so no hardware UUIDs ever need to be pasted into this repo. After install,
# `nixos-rebuild` never touches the partition table again.
#
# The host must also import `inputs.disko.nixosModules.disko` (done in
# modules/hosts.nix, same pattern as nixos-wsl providing the `wsl.*` options).
#
# ⚠️  Running disko WIPES the target device. Only run it from the installer
#     ISO, and verify the device path with `lsblk` first.
#     See notes/SETUP-NIXOS-LAPTOP.md for the full install procedure.
{
  flake.modules.nixos.laptopDisko = {
    disko.devices.disk.main = {
      type = "disk";
      # TODO(install day): confirm with `lsblk` on the live ISO —
      # a SATA SSD shows up as /dev/sda instead of /dev/nvme0n1.
      device = "/dev/nvme0n1";
      content = {
        type = "gpt";
        partitions = {
          # EFI system partition — systemd-boot lives here (see laptop.nix).
          esp = {
            priority = 1;
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          # Everything else: one LUKS2 container holding a btrfs filesystem.
          # The passphrase is set interactively during install and asked at
          # every boot; disko wires up boot.initrd.luks automatically.
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "cryptroot";
              settings.allowDiscards = true; # let SSD TRIM pass through LUKS
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                # Subvolume split rationale:
                #   @home gets snapshotted (user data — NixOS generations
                #   already cover system rollback); @nix is kept separate so
                #   snapshots never drag along the multi-GB reproducible store.
                subvolumes = {
                  "@root" = {
                    mountpoint = "/";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "@snapshots" = {
                    mountpoint = "/.snapshots";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  # Swapfile in a dedicated subvolume; disko marks it no-CoW
                  # (btrfs requirement for swapfiles). No hibernation.
                  "@swap" = {
                    mountpoint = "/.swapvol";
                    swap.swapfile.size = "8G"; # TODO(install day): match to RAM if desired
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
