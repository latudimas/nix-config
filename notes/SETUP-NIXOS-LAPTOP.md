# Installing NixOS on the HP ProBook 430 G5 (dims-laptop)

Fresh install using the declarative disk layout in `modules/nixos/laptop-disko.nix`
(disko: GPT → 1G ESP + LUKS2 → btrfs subvolumes). See issue #4 for the design
discussion. Everything below runs on the **laptop**, booted from the installer ISO.

## 0. Before wiping anything

- Back up whatever on the laptop still matters.
- Download the **graphical** NixOS ISO (GNOME or Plasma — either is fine) and
  write it to a USB stick, boot it (F9 = boot menu on most HPs of this era;
  disable Secure Boot in BIOS if the ISO refuses to boot).
  We do NOT use the click-through Calamares installer on it (it would bypass
  the disko layout) — we only want the live desktop for easy wifi (GUI network
  icon) and a browser, then run the install from a terminal. The minimal ISO
  works too; then wifi is joined via `wpa_cli` as in step 1.

## 1. Get online + gather facts

```bash
# wifi (skip if ethernet)
sudo systemctl start wpa_supplicant
wpa_cli   # > add_network / set_network 0 ssid "..." / set_network 0 psk "..." / enable_network 0

# disk device — MUST match `device` in modules/nixos/laptop-disko.nix
lsblk
# NVMe SSD → /dev/nvme0n1 (current value) ; SATA SSD → /dev/sda (edit the file!)
```

Tip: this can be checked from Windows beforehand — PowerShell:
`Get-PhysicalDisk | Select FriendlyName,BusType` (`NVMe` → current value is
right; `SATA` → edit laptop-disko.nix to `/dev/sda`).

If the device path differs, fix it in the repo, push, and continue — the
install below pulls the flake straight from GitHub.

Hardware already confirmed (issue #4): i5-8250U, 16GB RAM (8G swapfile is
final), WD PC SN520 256GB **NVMe** SSD (→ `/dev/nvme0n1`, the current value),
UHD 620. The `lsblk` check above is just a final sanity pass.

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

## Alternative: automated install with nixos-anywhere (from the Mac)

Replaces steps 2–4 with one command driven from `smol`; steps 0–1 and 5 stay
the same. On the laptop (booted into the live ISO, wifi connected):

```bash
passwd   # set any temporary password for the live `nixos` user
ip a     # note the laptop's IP address
```

Then on the Mac:

```bash
cd ~/.config/nix-config
nix run github:nix-community/nixos-anywhere -- \
  --flake .#dims-laptop \
  --build-on-remote \
  --target-host nixos@<laptop-ip>
```

nixos-anywhere SSHes in, runs disko (asks the LUKS passphrase — this is the
boot passphrase), builds the system on the laptop (`--build-on-remote`
because the Mac is aarch64-darwin and can't build x86_64-linux), installs,
and reboots. It uses the local checkout, so nothing needs to be pushed first.

Note: this path installs with the generic module list in
`laptop-hardware.nix` as-is (fine for this machine). After first boot, run
step 3's `nixos-generate-config --no-filesystems` on the running system and
reconcile at leisure.

## Post-install checklist

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
