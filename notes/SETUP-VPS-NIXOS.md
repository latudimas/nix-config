# Setup Guide: NixOS VPS + This Config Repo (via nixos-anywhere)

This guide covers converting a KVM-based VPS to NixOS using `nixos-anywhere`
and applying this config repo to it. Run everything from your local Mac.

---

## Prerequisites

- VPS with KVM virtualization (NOT OpenVZ — check with your provider)
- Root SSH access to the VPS
- This config repo on your local Mac
- Nix + flakes enabled locally (already the case on `smol`)

Verify kexec support on your VPS:
```bash
ssh root@<vps-ip> "ls /proc/sys/kernel/kexec_loaded"
# Should return: /proc/sys/kernel/kexec_loaded (file exists)
```

---

## Step 1: Update the Flake to Support NixOS VPS

The current `vps` entry is `homeConfigurations` (home-manager standalone).
Replace it with a proper `nixosConfigurations` entry.

### 1a. Update `flake.nix`

Remove:
```nix
# VPS — home-manager standalone (minimal packages)
homeConfigurations."vps" = home-manager.lib.homeManagerConfiguration {
  pkgs = nixpkgs-stable.legacyPackages."x86_64-linux";
  modules = [ ./hosts/vps ];
};
```

Add:
```nix
# VPS — NixOS + home-manager (minimal)
nixosConfigurations.vps = nixpkgs-stable.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    ./hosts/vps/configuration.nix
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "hm-backup";
      home-manager.users.dims = import ../../home/vps.nix;
    }
  ];
};
```

> Note: Uses `home/vps.nix` (minimal) instead of `home/dims.nix` (full dev setup).
> Create `home/vps.nix` in Step 1b.

### 1b. Create `home/vps.nix` (minimal home config for VPS)

```nix
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    neovim
    ripgrep
    git
    curl
    btop
    bat
  ];

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    settings.user.name = "latudimas";
    settings.user.email = "riswandha.ld@gmail.com";
    settings.init.defaultBranch = "main";
  };

  home.username = "dims";
  home.homeDirectory = "/home/dims";
  home.stateVersion = "24.11";
}
```

### 1c. Create `hosts/vps/configuration.nix`

Replace `hosts/vps/default.nix` with a proper NixOS system config:

```nix
{ pkgs, ... }:
{
  # Boot — most KVM VPS providers use GRUB
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda"; # adjust to your VPS disk

  # Filesystem — adjust to match your VPS disk layout
  fileSystems."/" = {
    device = "/dev/sda1";
    fsType = "ext4";
  };

  # Networking
  networking.hostName = "vps";
  networking.useDHCP = true;

  # SSH — keep enabled so you don't lock yourself out
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
    settings.PasswordAuthentication = false;
  };

  # User account
  users.users.dims = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      # paste your public SSH key here
      "ssh-ed25519 AAAA... dims@smol"
    ];
  };

  # Allow sudo
  security.sudo.wheelNeedsPassword = false;

  # Nix settings
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "dims" ];
    substituters = [ "https://dims-nix.cachix.org" ];
    trusted-public-keys = [ "dims-nix.cachix.org-1:<key from cachix dashboard>" ];
  };

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.11";
}
```

> **Important before running:** Verify the disk device name on your current VPS:
> ```bash
> ssh root@<vps-ip> "lsblk"
> ```
> Common values: `/dev/sda`, `/dev/vda`, `/dev/nvme0n1`
> Adjust `boot.loader.grub.device` and `fileSystems` accordingly.

---

## Step 2: Commit the Config Changes

```bash
cd ~/.config/nix-darwin
git add .
git commit -m "feat: add nixos vps configuration"
```

nixos-anywhere will pull from the local repo, so changes must be on disk (commit not required but clean state helps).

---

## Step 3: Run nixos-anywhere from Your Mac

```bash
nix run github:nix-community/nixos-anywhere -- \
  --flake .#vps \
  root@<vps-ip>
```

What happens:
1. nixos-anywhere SSHes into your VPS as root
2. Loads a minimal NixOS installer into RAM via kexec (original OS untouched so far)
3. Partitions the disk and installs NixOS from your flake
4. Reboots into fresh NixOS

> This will **wipe the disk** and install NixOS. Back up any VPS data first.
> The process is typically 5–15 minutes depending on VPS speed.

---

## Step 4: First SSH Into the New NixOS VPS

```bash
ssh dims@<vps-ip>
```

If SSH host key changed (it will), clear the old one first:
```bash
ssh-keygen -R <vps-ip>
```

---

## Step 5: Clone Config Repo on the VPS (Optional)

If you want to apply updates directly from the VPS:
```bash
git clone https://github.com/<your-repo>/nix-darwin ~/.config/nix-darwin
```

---

## Ongoing Updates

### From your local Mac (recommended):
```bash
# Deploy config changes remotely without SSHing in
nixos-rebuild switch --flake .#vps --target-host dims@<vps-ip> --use-remote-sudo
```

### From inside the VPS:
```bash
cd ~/.config/nix-darwin
sudo nixos-rebuild switch --flake .#vps
```

---

## Rollback if Something Breaks

NixOS keeps all previous generations:
```bash
# From Mac
nixos-rebuild switch --flake .#vps --target-host dims@<vps-ip> --use-remote-sudo --rollback

# From inside VPS
sudo nixos-rebuild switch --rollback
```

---

## Update the GitHub Actions Workflow

Once migrated, update `.github/workflows/nix.yml` to build the NixOS config:

```yaml
- name: Build Linux hosts
  run: |
    nix build .#nixosConfigurations.dims-work.config.system.build.toplevel --no-link
    nix build .#nixosConfigurations.vps.config.system.build.toplevel --no-link
```

Replace the old `homeConfigurations.*.activationPackage` lines.
