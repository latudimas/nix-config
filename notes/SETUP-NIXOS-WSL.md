# Setup Guide: NixOS-WSL + This Config Repo

This guide covers installing NixOS on WSL2 and applying this config repo to it.
NixOS-WSL gives full declarative system config, unlike Ubuntu WSL + home-manager standalone.

> **Note:** NixOS-WSL has historically been buggy on this setup.
> This guide is for future reference when it matures enough to try again.

---

## Prerequisites

- Windows 10/11 with WSL2 enabled
- PowerShell with admin access
- This config repo cloned somewhere on Windows or accessible from WSL

---

## Step 1: Enable WSL2 (if not already)

Run in PowerShell as Administrator:
```powershell
wsl --install --no-distribution
wsl --set-default-version 2
```

Restart Windows if prompted.

---

## Step 2: Download NixOS-WSL

Get the latest release tarball from:
https://github.com/nix-community/NixOS-WSL/releases

Download `nixos-wsl.tar.gz` (x86_64 build).

---

## Step 3: Import and Start NixOS-WSL

```powershell
# Import the distro (adjust paths as needed)
wsl --import NixOS C:\wsl\nixos\ C:\Downloads\nixos-wsl.tar.gz --version 2

# Start it
wsl -d NixOS
```

Default user inside is `nixos`. You'll be root or nixos on first boot.

---

## Step 4: Enable Flakes (Inside NixOS-WSL)

```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

---

## Step 5: Update the Flake to Support NixOS-WSL

The current `dims-work` entry is `homeConfigurations` (home-manager standalone).
For NixOS-WSL, it needs to become a `nixosConfigurations` entry.

### 5a. Add nixos-wsl input to `flake.nix`

```nix
inputs = {
  # ... existing inputs ...

  nixos-wsl = {
    url = "github:nix-community/NixOS-WSL";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
```

Also add `nixos-wsl` to the outputs arguments:
```nix
outputs = { self, nix-darwin, nixpkgs, nixpkgs-stable, home-manager, nixos-wsl, ... }:
```

### 5b. Replace the `dims-work` homeConfiguration with nixosConfiguration

Remove:
```nix
# WSL — home-manager standalone (full config)
homeConfigurations."dims-work" = home-manager.lib.homeManagerConfiguration {
  pkgs = nixpkgs.legacyPackages."x86_64-linux";
  modules = [ ./hosts/dims-work ];
};
```

Add:
```nix
# WSL — NixOS-WSL + home-manager
nixosConfigurations.dims-work = nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    nixos-wsl.nixosModules.default
    ./hosts/dims-work/configuration.nix
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "hm-backup";
      home-manager.users.dims = import ../../home/dims.nix;
    }
  ];
};
```

### 5c. Create `hosts/dims-work/configuration.nix`

Replace `hosts/dims-work/default.nix` with a proper NixOS system config:

```nix
{ pkgs, ... }:
{
  # WSL settings
  wsl.enable = true;
  wsl.defaultUser = "dims";

  # User account
  users.users.dims = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
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

---

## Step 6: Clone Config Repo Inside NixOS-WSL

```bash
# Inside NixOS-WSL
mkdir -p ~/.config
git clone https://github.com/<your-repo>/nix-darwin ~/.config/nix-config
cd ~/.config/nix-config
```

---

## Step 7: Apply the Configuration

```bash
# From inside the repo directory
sudo nixos-rebuild switch --flake .#dims-work
```

This will:
- Apply the NixOS system config (WSL settings, user, nix daemon)
- Apply home-manager config (zsh, tmux, git, helix, all your tools)

---

## Step 8: Set Default WSL Distro (Optional)

From PowerShell:
```powershell
wsl --set-default NixOS
```

---

## Ongoing Updates

After making changes to the config:
```bash
cd ~/.config/nix-config
sudo nixos-rebuild switch --flake .#dims-work
```

Or using the `drf` alias equivalent — you can add a Linux alias in `zsh.nix`:
```nix
nrs = "sudo nixos-rebuild switch --flake ~/.config/nix-config";
```

---

## Rollback if Something Breaks

NixOS keeps previous generations:
```bash
sudo nixos-rebuild switch --rollback
# or pick a specific generation:
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
sudo nixos-rebuild switch --profile-name <generation>
```
