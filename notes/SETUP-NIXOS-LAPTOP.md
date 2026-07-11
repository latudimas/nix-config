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
  works too; then wifi is joined via `wpa_cli` as in step 1 — see the
  minimal-ISO alternative section near the bottom for what else differs.

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

1. Enter the LUKS passphrase, log in as `dims` via tuigreet with the initial
   password `changeme` (set declaratively in laptop.nix), then **immediately
   run `passwd`** in a terminal to replace it. The change sticks — the
   initial password only applies when the user is first created.
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

Unlike `nixos-install`, this path never prompts for a root password — the
`initialHashedPassword` on the `dims` user in laptop.nix is the only login
that works after reboot (see issue #6). Don't remove it before installing.

Note: this path installs with the generic module list in
`laptop-hardware.nix` as-is (fine for this machine). After first boot, run
step 3's `nixos-generate-config --no-filesystems` on the running system and
reconcile at leisure.

## Alternative: installing from the minimal ISO

Steps 2–5 are identical — the minimal ISO only changes what the live
environment looks like. Differences from the graphical ISO:

- You land on a **TTY**, auto-logged-in as the `nixos` user (`sudo -i` for a
  root shell). There is no browser: keep this guide open on another device,
  or SSH in from the Mac (below) and copy-paste from there.
- No GUI network icon — join wifi with the `wpa_cli` flow from step 1.
- US keyboard layout by default; `sudo loadkeys <layout>` if needed.

Recommended: drive the install over SSH from the Mac instead of typing at
the laptop console. sshd already runs on the ISO; it only needs the live
`nixos` user to have a password:

```bash
# on the laptop (after wifi is up)
passwd            # any temporary password for the live `nixos` user
ip a              # note the laptop's IP

# on the Mac
ssh nixos@<laptop-ip>
```

From that SSH session run steps 2–4 exactly as written (`sudo` needs no
password on the ISO). Note these are the same two laptop-side commands the
nixos-anywhere path needs — if you're on the minimal ISO anyway, that fully
automated path is the natural choice.

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
