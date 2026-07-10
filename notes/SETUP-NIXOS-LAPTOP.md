# Installing NixOS on the HP laptop (dims-laptop)

Fresh install using the declarative disk layout in `modules/nixos/laptop-disko.nix`
(disko: GPT → 1G ESP + LUKS2 → btrfs subvolumes). See issue #4 for the design
discussion. Everything below runs on the **laptop**, booted from the installer ISO.

## 0. Before wiping anything

- Back up whatever on the laptop still matters.
- Download the minimal NixOS ISO and write it to a USB stick, boot it
  (F9 = boot menu on most HPs of this era; disable Secure Boot in BIOS if
  the ISO refuses to boot).

## 1. Get online + gather facts

```bash
# wifi (skip if ethernet)
sudo systemctl start wpa_supplicant
wpa_cli   # > add_network / set_network 0 ssid "..." / set_network 0 psk "..." / enable_network 0

# exact model — decides whether to uncomment the nixos-hardware import in hosts.nix
sudo dmidecode -s system-product-name

# disk device — MUST match `device` in modules/nixos/laptop-disko.nix
lsblk
# NVMe SSD → /dev/nvme0n1 (current value) ; SATA SSD → /dev/sda (edit the file!)

# RAM — adjust the 8G swapfile in laptop-disko.nix if you want swap ≈ RAM
free -h
```

If anything differs (model / device path / RAM), fix it in the repo, push, and
continue — the install below pulls the flake straight from GitHub.

## 2. Partition + format (DESTROYS THE DISK)

```bash
sudo nix --experimental-features "nix-command flakes" \
  run github:nix-community/disko/latest -- \
  --mode destroy,format,mount \
  --flake github:latudimas/nix-config#dims-laptop
```

You'll be asked for the LUKS passphrase here — this is the passphrase the
laptop will ask for at every boot. Afterwards the target layout is mounted
under `/mnt` (check with `findmnt -R /mnt`).

## 3. Capture the hardware config

```bash
nixos-generate-config --no-filesystems --root /mnt
cat /mnt/etc/nixos/hardware-configuration.nix
```

Copy `boot.initrd.availableKernelModules` / `boot.kernelModules` into
`modules/nixos/laptop-hardware.nix` (replacing the generic placeholder list),
commit and push. Keep the flake-parts wrapper — only replace the lists.
The `fileSystems.*` entries in the generated file are disko's job; ignore them.

## 4. Install

```bash
sudo nixos-install --flake github:latudimas/nix-config#dims-laptop
# set the root password when prompted
reboot
```

## 5. First boot

1. Enter the LUKS passphrase, log in as `dims` via tuigreet (set a password
   first: log in as root on a TTY, `passwd dims`).
2. tuigreet launches Hyprland. Default keybinds: `SUPER+Q` terminal (kitty),
   `SUPER+R` launcher (wofi), `SUPER+M` exit.
3. Clone this repo so future rebuilds are local:
   ```bash
   git clone git@github.com:latudimas/nix-config.git ~/.config/nix-config
   sudo nixos-rebuild switch --flake ~/.config/nix-config#dims-laptop
   ```

## Post-install checklist

- [ ] Model confirmed → uncomment `inputs.nixos-hardware.nixosModules.hp-probook-440G5`
      in `modules/hosts.nix` (if it's really a 440 G5), rebuild
- [ ] `laptop-hardware.nix` placeholder replaced with generated module lists
- [ ] btrfs compression working: `sudo compsize /` (add `compsize` ad hoc via `nix shell nixpkgs#compsize`)
- [ ] Write `modules/home/hyprland.nix` aspect once the Hyprland config
      outgrows the defaults (bar, wallpaper, lock screen, keybinds)

## Day-to-day

Partitioning was a one-time install step — `nixos-rebuild` never touches the
partition table. Rebuilds work exactly like on `dims-wsl`:

```bash
sudo nixos-rebuild switch --flake ~/.config/nix-config#dims-laptop
```
