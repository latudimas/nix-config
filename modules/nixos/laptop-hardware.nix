# modules/nixos/laptop-hardware.nix — machine-generated hardware quirks.
# ============================================================================
# The non-filesystem half of what `nixos-generate-config` produces (disko owns
# the filesystem half, so the generated `fileSystems.*` entries are ignored).
#
# PLACEHOLDER until install day:
#   1. On the installer ISO (after disko has mounted /mnt), run:
#        nixos-generate-config --no-filesystems --root /mnt
#   2. Replace the kernel-module lists below with the ones from the generated
#      /mnt/etc/nixos/hardware-configuration.nix.
#
# The generic list below covers typical 2019 Intel laptops, so the config
# evaluates and installs even before that step. NOTE: this file must stay a
# flake-parts wrapper — import-tree imports every .nix under modules/, so a
# raw hardware-configuration.nix dropped in here would break evaluation.
{
  flake.modules.nixos.laptopHardware = {
    # TODO(install day): replace with the generated list.
    boot.initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "nvme"
      "usb_storage"
      "sd_mod"
      "rtsx_pci_sdmmc"
    ];
    boot.kernelModules = [ "kvm-intel" ];

    # Intel CPU microcode updates + wifi/bluetooth/GPU firmware blobs.
    hardware.cpu.intel.updateMicrocode = true;
    hardware.enableRedistributableFirmware = true;
  };
}
