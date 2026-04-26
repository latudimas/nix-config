# Complete Usage Guide

How to set up, apply, and maintain this config repo across all devices.

---

## Device Overview

| Device | OS | Config type | Apply command |
|---|---|---|---|
| `smol` | macOS (Apple Silicon) | nix-darwin + home-manager | `darwin-rebuild switch --flake .` |
| `dims-work` | Ubuntu WSL (x86_64) | home-manager standalone | `home-manager switch --flake .#dims-work` |
| `vps` | Debian (x86_64) | home-manager standalone | `home-manager switch --flake .#vps` |

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

This adds `dims` to `trusted-users` and registers the Cachix substituter
in `/etc/nix/nix.conf`. Only needed once per machine.

**4. Apply config**
```bash
nix run home-manager -- switch --flake .#dims-work
```

> After first run, `home-manager` is available directly:
```bash
home-manager switch --flake ~/.config/nix-config#dims-work
```

---

### vps (Debian)

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

**4. Apply config**
```bash
nix run home-manager -- switch --flake .#vps
```

> After first run:
```bash
home-manager switch --flake ~/.config/nix-config#vps
```

---

## Day-to-Day: Applying Config Changes

After editing any file in this repo, apply the changes with:

| Device | Command | Short alias |
|---|---|---|
| `smol` | `darwin-rebuild switch --flake ~/.config/nix-config` | `drf ~/.config/nix-config` |
| `dims-work` | `home-manager switch --flake ~/.config/nix-config#dims-work` | — |
| `vps` | `home-manager switch --flake ~/.config/nix-config#vps` | — |

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

Packages in this repo track `nixpkgs-unstable` (for smol and dims-work)
and `nixos-24.11` stable (for vps). "Updating" means pulling the latest
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
nix flake update nixpkgs          # update only nixpkgs-unstable
nix flake update nixpkgs-stable   # update only stable channel
nix flake update home-manager     # update only home-manager
```

### Check what will change before updating
```bash
nix flake update --commit-lock-file  # updates and commits in one step
```

---

## Adding a New Package

### To all non-VPS devices (smol + dims-work)

Edit `modules/packages/cli.nix` and add the package:
```nix
home.packages = with pkgs; [
  # existing packages...
  your-new-package
];
```

Then apply on each device.

### To smol only (macOS-specific)

Add directly to `hosts/smol/default.nix` or a new macOS-only module.

### To dims-work only (WSL-specific)

Add directly to `hosts/dims-work/default.nix`.

### To vps only

Add to `hosts/vps/default.nix`.

### Enabling a commented-out language/tool

Some modules are pre-configured but disabled. To enable:

```nix
# modules/development/default.nix
imports = [
  ./nodejs.nix
  ./python.nix  # remove the # to enable
  ./zig.nix     # remove the # to enable
];
```

```nix
# modules/shell/default.nix
imports = [
  ./zsh.nix
  ./nushell.nix  # uncomment to switch back to nushell
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

### dims-work / vps (home-manager)

```bash
# List all generations
home-manager generations

# Roll back to a specific generation (copy the path from the list)
home-manager switch --profile-name /nix/var/nix/profiles/per-user/dims/home-manager-<N>-link
```

---

## Repo Structure Quick Reference

```
flake.nix                   # entry point, defines all three hosts
hosts/
  smol/
    default.nix             # home-manager wiring for Mac
    system.nix              # nix-darwin system config (nix daemon, shell, Cachix)
  dims-work/
    default.nix             # home-manager config for WSL
  vps/
    default.nix             # home-manager config for VPS (minimal)
home/
  dims.nix                  # shared home-manager config (imported by smol + dims-work)
modules/
  development/              # nodejs, python, zig (enable/disable in default.nix)
  packages/                 # cli tools, git config
  shell/                    # zsh, tmux, direnv, helix, ai tools
scripts/
  setup-linux.sh            # one-time setup for WSL/VPS (run once after cloning)
notes/                      # reference docs (this file and others)
```

---

## CI / GitHub Actions

On every push to `main`: builds all three host configs and pushes to Cachix.
On every pull request: runs `nix flake check --no-build` (fast validation).

No manual action needed — just push and CI handles the rest.
See `.github/workflows/nix.yml`.
