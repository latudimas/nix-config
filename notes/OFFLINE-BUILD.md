# Offline / Slow Internet Build

By default, `darwin-rebuild switch` pulls pre-built binaries from Cachix and cache.nixos.org.
When internet is slow or unavailable, use these aliases instead.

## Aliases

| Alias | Behavior |
|---|---|
| `drf` | Normal — uses Cachix + nixos cache (fastest when online) |
| `drf-fast` | Tries cache first, falls back to local build if download fails |
| `drf-off` | Skips all substituters, builds 100% locally (no network needed) |

> These aliases are defined in `modules/shell/zsh.nix`.

## When to Use Each

- **`drf`** — daily use, good internet connection
- **`drf-fast`** — spotty connection, travelling, tethering; won't error if Cachix is slow
- **`drf-off`** — fully offline, or when you want a clean local build to verify everything compiles

## The Nix Flags Behind Them

```bash
# drf-fast
darwin-rebuild switch --flake . --fallback

# drf-off
darwin-rebuild switch --flake . --option substitute false
```

These flags also work with any other nix command:

```bash
nix build .#somePackage --fallback
nix build .#somePackage --option substitute false
```
