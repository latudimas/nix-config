# Why We Can't Declaratively Manage System Config on WSL and VPS

## The Core Difference

| Machine | OS Manager | Nix Role |
|---|---|---|
| `smol` (Mac) | nix-darwin | **IS the system manager** |
| `dims-work` (WSL) | Ubuntu | Just a package manager on top |
| `vps` (Debian) | Debian | Just a package manager on top |

## What nix-darwin Actually Does

nix-darwin is essentially "NixOS for macOS". It takes full ownership of system-level
configuration:

- `/etc/` files (shells, hosts, nix settings)
- System packages (available to all users)
- Launchd services (macOS equivalent of systemd)
- Nix daemon settings (substituters, trusted-users, experimental features)

When you run `darwin-rebuild switch`, nix-darwin rewrites all of this from your config.
That's why `system.nix` can control things like `nix.settings.substituters` — it's
writing directly to `/etc/nix/nix.conf` on your behalf.

## What home-manager Can Do

home-manager only manages **user-level** things:

- `~/.config/` files
- Packages in the user's profile (`~/.nix-profile/`)
- User shell config, aliases, env vars
- User-level program config (git, zsh, tmux, helix...)

It cannot touch `/etc/`, system packages, or the Nix daemon config because those
require root — and home-manager runs as your user.

## Why WSL and VPS Are Limited

On Ubuntu WSL and Debian VPS, Nix is installed as a **package manager on top of an
existing OS**. The OS itself (systemd, /etc, bootloader, kernel) is still managed by
Ubuntu/Debian, not Nix.

So:
- `nix.settings` in home-manager writes to `~/.config/nix/nix.conf` (user-level only)
- For substituters to work, the Nix daemon (running as root) reads `/etc/nix/nix.conf`
- home-manager can't write there — only root can
- Result: substituters must be set manually in `/etc/nix/nix.conf`

## The Full Solution: NixOS

If the machine runs NixOS, Nix is the OS — there's no Ubuntu/Debian underneath.
NixOS manages `/etc/`, the kernel, services, everything. This gives the same
declarative power as nix-darwin:

```
nix.settings.substituters = [ "https://dims-nix.cachix.org" ];
```

...just works, because NixOS owns `/etc/nix/nix.conf`.

## Summary

You can't manage system config declaratively on WSL/VPS because those machines run
Nix as a guest on an existing OS. nix-darwin (and NixOS) work declaratively because
they ARE the system manager — there's no other OS layer underneath doing its own thing.

The only path to fully declarative WSL/VPS is:
- WSL → NixOS-WSL (tried, too buggy)
- VPS → nixos-anywhere or fresh NixOS install (see NIXOS-INFECT.md)
