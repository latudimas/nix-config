# nix-config

Multi-device Nix configuration for macOS, NixOS-WSL, and Debian/Ubuntu VPSes.
Built with Nix flakes, [flake-parts](https://flake.parts/), [import-tree](https://github.com/vic/import-tree), [nix-darwin](https://github.com/LnL7/nix-darwin), and [home-manager](https://github.com/nix-community/home-manager).

## Hosts

| Host | OS | Type | Apply command |
|---|---|---|---|
| `smol` | macOS (Apple Silicon) | nix-darwin + home-manager | `darwin-rebuild switch --flake .` |
| `dims-wsl` | NixOS on WSL | NixOS + home-manager | `sudo nixos-rebuild switch --flake .#dims-wsl` |
| `dims-work` | Ubuntu WSL (x86_64) | home-manager standalone | `home-manager switch --flake .#dims-work` |
| `vps-dims` | Debian/Ubuntu VPS | home-manager standalone | `home-manager switch --flake .#vps-dims` |
| `vps-dudidam` | Debian/Ubuntu VPS | home-manager standalone | `home-manager switch --flake .#vps-dudidam` |

`vps-dudidam` exists because the new VPS provider enforces a maximum username length; the config is otherwise identical to `vps-dims`.

## Quick start

**1. Install Nix**

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Restart your shell.

**2. Clone this repo**

```bash
git clone https://github.com/latudimas/nix-config ~/.config/nix-config
cd ~/.config/nix-config
```

**3. One-time Linux setup (WSL / VPS only)**

```bash
bash scripts/setup-linux.sh
```

This adds your user to Nix `trusted-users` and registers the `dims-nix` Cachix substituter in `/etc/nix/nix.conf`. Run once per machine.

**4. Apply the config**

macOS (first time):

```bash
nix run nix-darwin -- switch --flake .#smol
```

After the first run, use `darwin-rebuild switch --flake .`.

Linux/WSL/VPS (first time):

```bash
nix run home-manager -- switch --flake .#<host>
```

After the first run, `home-manager` is on `PATH`:

```bash
home-manager switch --flake ~/.config/nix-config#<host>
```

## Project structure

```text
flake.nix              # flake entry point
modules/
  hosts.nix            # assembles aspects into real machines
  systems.nix          # flake-parts systems wiring
  nix-cache.nix        # dims-nix Cachix cache config
  home/                # home-manager aspects (zsh, cli, git, ...)
  darwin/              # nix-darwin aspects
  nixos/               # NixOS aspects
scripts/
  setup-linux.sh       # one-time Linux/WSL/VPS setup
notes/                 # additional reference docs
```

The repo uses a **dendritic** pattern: every `.nix` file under `modules/` is a flake-parts module that registers reusable aspects under `flake.modules.<class>.<name>`. `modules/hosts.nix` picks which aspects each machine uses.

## Profiles

- **`fullHome`** — complete developer setup used by `smol`, `dims-wsl`, and `dims-work`.
- **`minimalHome`** — lighter setup used by the VPS hosts (`vps-dims`, `vps-dudidam`).

Shared server extras (currently `neovim`) live in `modules/hosts.nix` so both VPSes stay in sync.

## Day-to-day usage

Update flake inputs:

```bash
nix flake update
```

Apply changes:

```bash
darwin-rebuild switch --flake ~/.config/nix-config
# or
home-manager switch --flake ~/.config/nix-config#<host>
```

Check without building:

```bash
nix flake check --no-build
```

Rollback home-manager:

```bash
home-manager generations
home-manager switch --profile-name /nix/var/nix/profiles/per-user/<user>/home-manager-<N>-link
```

## Adding things

- **Packages for all non-VPS devices**: edit `modules/home/cli.nix` or add a new aspect in `modules/home/` and import it in `fullHome`.
- **Packages for VPSes only**: add them to `vpsExtras` in `modules/hosts.nix`.
- **New host**: add a new entry in `modules/hosts.nix` and compose the aspects you need.

## Binary cache

This flake uses the `dims-nix` Cachix cache. The Linux setup script registers it system-wide; macOS and NixOS-WSL handle it via their respective system modules.

## CI

`.github/workflows/nix.yml` runs on every push:

- `nix flake check --no-build`
- Full builds of all hosts, pushed to `dims-nix` Cachix.
