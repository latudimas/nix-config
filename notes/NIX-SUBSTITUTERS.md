# Nix Substituters & Cachix Setup for Linux

## What Is a Substituter?

A substituter is a binary cache — a server that stores pre-built Nix packages.
When you run any `nix build` or `home-manager switch`, Nix doesn't immediately
compile from source. It first asks: "has anyone already built this exact thing?"
If a substituter has it, Nix downloads the pre-built result instead of compiling.

```
Without substituter:   nix build → compile from source (slow, minutes/hours)
With substituter:      nix build → download pre-built binary (fast, seconds)
```

The default substituter every Nix install knows about is `cache.nixos.org`.
It caches official nixpkgs packages. Your personal config and custom derivations
are NOT there — that's what your own Cachix cache is for.

## What Are the Different Substituter Settings?

| Setting | Scope | Who Can Set It |
|---|---|---|
| `substituters` | Replaces the default list | Root only (`/etc/nix/nix.conf`) |
| `extra-substituters` | Appends to the default list | Trusted users (user config) |
| `trusted-public-keys` | Replaces the default key list | Root only |
| `extra-trusted-public-keys` | Appends to the default key list | Trusted users (user config) |

Always prefer `extra-substituters` over `substituters` — using `substituters` alone
would remove `cache.nixos.org` from the list, meaning Nix can't find any nixpkgs
packages either. `extra-substituters` keeps the defaults and adds yours on top.

## Why Does Cachix Need a Public Key?

Nix verifies every downloaded binary is signed by a trusted key.
This prevents a compromised cache from serving malicious binaries.
Each Cachix cache has its own signing key pair:
- **Private key**: used by CI to sign binaries when pushing (secret)
- **Public key**: used by your machine to verify downloads (safe to commit)

Without the public key in `extra-trusted-public-keys`, Nix will download from
Cachix but then reject the binaries as untrusted and compile from source anyway.

## Why `/etc/nix/nix.conf` Requires Root

The Nix **daemon** runs as root and is responsible for all actual building and
downloading. It reads its config from `/etc/nix/nix.conf` at startup.
Substituters are a security-sensitive setting (you're trusting an external binary
source), so only root can set them at the daemon level.

There is also a chicken-and-egg problem:

```
To use extra-substituters in user config → user must be in trusted-users
To be in trusted-users               → root must write to /etc/nix/nix.conf first
```

## The Two-Layer Solution

### Layer 1 — One-time root setup (imperative, once per machine)

Ensure `dims` is in `trusted-users` in `/etc/nix/nix.conf`:

```bash
grep trusted-users /etc/nix/nix.conf
# If dims is not listed, add it:
sudo bash -c 'echo "trusted-users = root dims" >> /etc/nix/nix.conf'
sudo systemctl restart nix-daemon
```

> The Determinate Systems Nix installer often adds the current user to
> `trusted-users` automatically, so this step may already be done.
> Always check before running.

### Layer 2 — Declarative via home-manager (after Layer 1)

Once the user is trusted, home-manager can manage the substituters declaratively.
Add to `hosts/dims-work/default.nix` (and similarly for VPS):

```nix
nix.settings = {
  extra-substituters = [ "https://dims-nix.cachix.org" ];
  extra-trusted-public-keys = [
    "dims-nix.cachix.org-1:<key from cachix dashboard>"
  ];
};
```

home-manager writes this to `~/.config/nix/nix.conf`. Because the user is trusted,
the daemon respects these settings. No root needed for any future config changes.

## One-Time Setup Script (Convenience)

A script in the repo handles both layers at once for a fresh Linux machine.
See `scripts/setup-linux.sh` — run it once after cloning the repo:

```bash
bash ~/.config/nix-darwin/scripts/setup-linux.sh
```

After that, all substituter config lives declaratively in the nix config.

## Where Substituters Are Used in This Repo

| Machine | How substituters are set |
|---|---|
| `smol` (Mac) | Declarative via `nix.settings` in `hosts/smol/system.nix` (nix-darwin owns `/etc/nix/nix.conf`) |
| `dims-work` (WSL) | Layer 1 once → Layer 2 via `nix.settings` in home-manager |
| `vps` (Debian) | Layer 1 once → Layer 2 via `nix.settings` in home-manager |

## Real-World Use Cases for Substituters

Beyond your own Cachix cache, substituters are also used for:

- **`cache.nixos.org`** — default, all official nixpkgs binaries
- **`nix-community.cachix.org`** — community packages (home-manager, neovim nightly, etc.)
- **`devenv.cachix.org`** — pre-built devenv environments (we use `devenv` in cli.nix)
- **Team/org caches** — share compiled derivations across a team so everyone benefits from CI builds
- **`nixpkgs-cuda-maintainers.cachix.org`** — GPU/CUDA packages that take hours to compile

You can add any of these the same way as your own Cachix cache using `extra-substituters`.
