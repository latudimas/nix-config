# Complete Usage Guide

How to set up, apply, and maintain this config repo across all devices.

---

## Device Overview

| Device | OS | Config type | Apply command |
|---|---|---|---|
| `smol` | macOS (Apple Silicon) | nix-darwin + home-manager | `darwin-rebuild switch --flake .` |
| `dims-wsl` | NixOS on WSL | NixOS + home-manager | `sudo nixos-rebuild switch --flake .#dims-wsl` |
| `dims-work` | Ubuntu WSL (x86_64) | home-manager standalone | `home-manager switch --flake .#dims-work` |
| `vps-dims` | Debian/Ubuntu VPS | home-manager standalone | `home-manager switch --flake .#vps-dims` |
| `vps-dudidam` | Debian/Ubuntu VPS | home-manager standalone | `home-manager switch --flake .#vps-dudidam` |

---

## First-Time Setup

### smol (Mac)

**1. Install Nix**
```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

**2. Clone the repo**
```bash
git clone https://github.com/latudimas/nix-config ~/.config/nix-config
cd ~/.config/nix-config
```

**3. Install nix-darwin**
```bash
nix run nix-darwin -- switch --flake .#smol
```

> After this first run, use `darwin-rebuild switch` or the `drf` alias for all future updates.

**4. Apply config**
```bash
darwin-rebuild switch --flake ~/.config/nix-config
# or using the alias (after step 3 completes):
drf ~/.config/nix-config
```

---

### dims-work (Ubuntu WSL)

**1. Install Nix (inside WSL)**
```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Restart the shell after installation.

**2. Clone the repo**
```bash
git clone https://github.com/latudimas/nix-config ~/.config/nix-config
cd ~/.config/nix-config
```

**3. Run the one-time Linux setup script**
```bash
bash scripts/setup-linux.sh
```

This adds the current user to `trusted-users` and registers the Cachix substituter
in `/etc/nix/nix.conf`. Only needed once per machine.

**4. Apply config**
```bash
nix run home-manager -- switch --flake .#dims-work
```

> After first run, `home-manager` is available directly:
```bash
home-manager switch --flake ~/.config/nix-config#dims-work
```

> **Why `nix run` first?** `home-manager` isn't installed yet on a fresh machine. `nix run` downloads and executes it temporarily so it can install itself permanently via `programs.home-manager.enable = true` in the flake. After that first bootstrap, the `home-manager` binary is in your PATH.

> **Set zsh as default shell:**
> Nix-installed zsh isn't in `/etc/shells` by default. Run as root first:
> ```bash
> echo "/home/dims/.nix-profile/bin/zsh" >> /etc/shells
> ```
> Then as `dims`:
> ```bash
> chsh -s $(which zsh)
> ```
> Log out and back in. This changes your login shell in `/etc/passwd` — home-manager alone cannot do this on non-NixOS Linux.

---

### VPS (Debian/Ubuntu)

There are two VPS outputs sharing the same minimal profile:

- `vps-dims` — username `dims`
- `vps-dudidam` — username `dudidam` (new provider enforces a max username length)

**1. Install Nix**
```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Restart the shell after installation.

**2. Clone the repo**
```bash
git clone https://github.com/latudimas/nix-config ~/.config/nix-config
cd ~/.config/nix-config
```

**3. Run the one-time Linux setup script**
```bash
bash scripts/setup-linux.sh
```

This uses the current user (or `SUDO_USER` if run with `sudo`) when adding `trusted-users`.

**4. Apply config**

Replace `<host>` with `vps-dims` or `vps-dudidam`:

```bash
nix run home-manager -- switch --flake .#<host>
```

> After first run:
```bash
home-manager switch --flake ~/.config/nix-config#<host>
```

> **Why `nix run` first?** `home-manager` isn't installed yet on a fresh machine. `nix run` downloads and executes it temporarily so it can install itself permanently via `programs.home-manager.enable = true` in the flake. After that first bootstrap, the `home-manager` binary is in your PATH.

> **Set zsh as default shell:**
> Nix-installed zsh isn't in `/etc/shells` by default. Run as root first:
> ```bash
> echo "$HOME/.nix-profile/bin/zsh" >> /etc/shells
> ```
> Then as the target user:
> ```bash
> chsh -s $(which zsh)
> ```
> Log out and back in. This changes your login shell in `/etc/passwd` — home-manager alone cannot do this on non-NixOS Linux.

---

## Day-to-Day: Applying Config Changes

After editing any file in this repo, apply the changes with:

| Device | Command | Short alias |
|---|---|---|
| `smol` | `darwin-rebuild switch --flake ~/.config/nix-config` | `drf ~/.config/nix-config` |
| `dims-wsl` | `sudo nixos-rebuild switch --flake ~/.config/nix-config#dims-wsl` | — |
| `dims-work` | `home-manager switch --flake ~/.config/nix-config#dims-work` | — |
| `vps-dims` | `home-manager switch --flake ~/.config/nix-config#vps-dims` | — |
| `vps-dudidam` | `home-manager switch --flake ~/.config/nix-config#vps-dudidam` | — |

> Always `cd` into the repo or provide the full path to the flake.

### Internet Toggle (smol only)

```bash
drf ~/.config/nix-config           # normal — uses Cachix (fastest)
drf-fast ~/.config/nix-config      # try cache, fall back to local build if slow
drf-off ~/.config/nix-config       # skip all caches, build 100% locally
```

See `notes/OFFLINE-BUILD.md` for details.

---

## Updating Package Versions

Packages in this repo track `nixpkgs-unstable`. "Updating" means pulling the latest
nixpkgs commit so packages get their newest versions.

### Update all flake inputs
```bash
cd ~/.config/nix-config
nix flake update
```

Then apply the config on each device as normal. Commit the updated `flake.lock`:
```bash
git add flake.lock
git commit -m "chore: update flake inputs"
git push
```

### Update a single input only
```bash
nix flake update nixpkgs      # update only nixpkgs
nix flake update home-manager # update only home-manager
nix flake update nix-darwin   # update only nix-darwin
```

### Check what will change before updating
```bash
nix flake update --commit-lock-file  # updates and commits in one step
```

---

## Adding a New Package

### To all non-VPS devices (smol + dims-work + dims-wsl)

Edit `modules/home/cli.nix` and add the package:
```nix
home.packages = with pkgs; [
  # existing packages...
  your-new-package
];
```

Then apply on each device.

### To smol only (macOS-specific)

Add a new darwin aspect in `modules/darwin/` and import it in `modules/hosts.nix` for `smol`.

### To dims-wsl only (NixOS-specific)

Add a new nixos aspect in `modules/nixos/` and import it in `modules/hosts.nix` for `dims-wsl`.

### To dims-work only (WSL-specific)

Add directly to the `dims-work` entry in `modules/hosts.nix`.

### To all VPSes

Add to `vpsExtras` in `modules/hosts.nix`.

### To one VPS only

Add an extra module to the specific `vps-dims` or `vps-dudidam` entry in `modules/hosts.nix`.

### Enabling a commented-out language/tool

Aspects live in `modules/home/`. To enable one on a host, import it in the profile lists in `modules/hosts.nix`:

```nix
fullHome = [
  hm.base
  # ...
  hm.python  # add this to enable Python tooling
];
```

---

## Rollback

### smol (nix-darwin)

```bash
# List all generations
darwin-rebuild --list-generations

# Roll back to previous generation
darwin-rebuild switch --rollback
```

### dims-work / vps-dims / vps-dudidam (home-manager)

```bash
# List all generations
home-manager generations

# Roll back to a specific generation (copy the path from the list)
home-manager switch --profile-name /nix/var/nix/profiles/per-user/<user>/home-manager-<N>-link
```

---

## Repo Structure Quick Reference

```
flake.nix                   # flake entry point
modules/
  hosts.nix                 # assembles aspects into real machines
  systems.nix               # flake-parts systems wiring
  nix-cache.nix             # dims-nix Cachix cache config
  home/                     # home-manager aspects (cli, git, zsh, ...)
  darwin/                   # nix-darwin aspects
  nixos/                    # NixOS aspects
scripts/
  setup-linux.sh            # one-time setup for Linux/WSL/VPS
notes/                      # reference docs (this file and others)
```

---

## CI / GitHub Actions

On every push to `main`: builds all host configs and pushes to Cachix.
On every pull request: runs `nix flake check --no-build` (fast validation).

No manual action needed — just push and CI handles the rest.
See `.github/workflows/nix.yml`.
