# Why Cachix Needs to Be Configured Locally

## How Nix Finds Pre-Built Binaries

When you run `darwin-rebuild switch` or any `nix build`, Nix doesn't immediately
compile from source. It first checks a list of **substituters** (binary caches) to
see if someone already built that exact derivation. If found, it downloads it.
If not found, it compiles locally.

The default substituter is `cache.nixos.org` — the official Nix binary cache.
It only contains packages from nixpkgs, not your personal configurations.

## The Problem

Your Cachix cache (`dims-nix.cachix.org`) is not in Nix's default substituter list.
So even if CI built and pushed your entire config to Cachix, your local machine
**won't check there** — it will compile everything from scratch, defeating the
whole point of having a cache.

```
Without local Cachix config:
  darwin-rebuild switch
  → checks cache.nixos.org  (your config? not found)
  → compiles from source     (slow)

With local Cachix config:
  darwin-rebuild switch
  → checks cache.nixos.org  (your config? not found)
  → checks dims-nix.cachix.org  (your config? FOUND → download)
  → fast
```

## Two Ways to Configure It

### Option A: Manual (imperative, one-time)

```bash
nix profile install nixpkgs#cachix
cachix authtoken <your-token>
cachix use dims-nix
```

`cachix use` writes the substituter URL and public key into `/etc/nix/nix.conf`.
Works, but it's a manual step every time you set up a new machine.

### Option B: Declarative via nix-darwin (recommended for smol)

In `hosts/smol/system.nix`:

```nix
nix.settings = {
  substituters = [ "https://dims-nix.cachix.org" ];
  trusted-public-keys = [ "dims-nix.cachix.org-1:<key from cachix dashboard>" ];
};
```

After `darwin-rebuild switch`, the Mac permanently knows about your cache.
No manual step, no `cachix` CLI needed. The public key is safe to commit.

> The auth token (for pushing) is only needed by CI (GitHub Actions secret).
> Reading from a public cache only requires the URL + public key.

### For WSL and VPS

Because they're not NixOS, the declarative option doesn't fully work
(see NIX-SYSTEM-VS-HOMEMANAGER.md). You need a one-time manual edit:

```bash
# Add to /etc/nix/nix.conf on the WSL/VPS machine
sudo bash -c 'echo "substituters = https://cache.nixos.org https://dims-nix.cachix.org" >> /etc/nix/nix.conf'
sudo bash -c 'echo "trusted-public-keys = cache.nixos.org-1:<key> dims-nix.cachix.org-1:<key>" >> /etc/nix/nix.conf'
sudo systemctl restart nix-daemon
```

This is a one-time setup per machine, not repeated on every config update.

## Where to Find Your Public Key

1. Go to cachix.org → your cache (`dims-nix`)
2. The public key is shown on the cache page
3. Format: `dims-nix.cachix.org-1:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx=`
