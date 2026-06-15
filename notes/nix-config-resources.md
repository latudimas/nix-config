# Nix Config — Learning Resources & Patterns

Curated list of resources for writing better / more idiomatic Nix configs,
plus notes on the two refactor patterns prototyped in this repo.

> Two proof-of-concept branches accompany these notes:
> - `dendritic-style`   → the Dendritic pattern (flake-parts + import-tree)
> - `idiomatic-modular` → the most common community pattern (helper functions + role-based modules)
>
> They live in sibling git worktrees:
> `../nix-config-dendritic` and `../nix-config-modular`.

---

## 1. Guides & Books (start here)

- **NixOS & Flakes Book** — https://nixos-and-flakes.thiscute.world
  Best modern guide for flakes + home-manager + multi-host. Read this first.
- **nix.dev** — https://nix.dev
  Official, well-maintained tutorials. Good for language/concept gaps.
- **Zero to Nix** (Determinate Systems) — https://zero-to-nix.com
  Gentle, flakes-first introduction. Good mental-model reset.

## 2. Example Repos (read like reference code)

- **Misterio77/nix-starter-configs** — https://github.com/Misterio77/nix-starter-configs
  The canonical idiomatic template. Shows how to kill per-host boilerplate.
- **Misterio77/nix-config** — https://github.com/Misterio77/nix-config
  The advanced/personal version of the starter.
- **ryan4yin/nix-config** — https://github.com/ryan4yin/nix-config
  Multi-host (macOS + Linux + servers) — matches our multi-device shape.
- **Mic92/dotfiles** — https://github.com/Mic92/dotfiles
  Large, battle-tested, lots of real-world patterns.
- **Bad3r/nixos** — https://github.com/Bad3r/nixos
  Real-world example of the Dendritic pattern.

## 3. Video

- **Vimjoyer** (YouTube) — short, focused, idiomatic "how should I structure X" videos.

## 4. Reference Tools (bookmark these)

- **search.nixos.org** — https://search.nixos.org — packages + NixOS options
- **Home Manager options** — https://home-manager-options.extranix.com
- **noogle.dev** — https://noogle.dev — search the Nix `lib` functions
- **flake.parts** — https://flake.parts — flake-parts docs

---

## 5. The Dendritic Pattern

A *convention* (not a library/framework) where **every `.nix` file is a flake-parts
module**, and all files are auto-discovered instead of manually imported. Named after
dendrites — the config becomes a branching tree of small, self-contained modules.

- Coined by **mightyiam** — https://github.com/mightyiam/dendritic
- Built on **flake-parts** + **vic/import-tree** — https://github.com/vic/import-tree

**Core idea — aspect-oriented, not host-oriented:** one file = one *feature/aspect*
(e.g. `git.nix`), and that single file can contribute to NixOS, nix-darwin, and
home-manager at once via `flake.modules.<class>.<aspect>`.

**Mechanics:**
1. `flake.nix` stays tiny — inputs + `mkFlake` + `import-tree ./modules`.
2. `import-tree` recursively imports every `.nix` file (no manual import lists).
3. Files/dirs with a `_` in their path are excluded from auto-import.
4. Shared values via `let`-bindings instead of `specialArgs`.

**Pros:** locality (one feature, one file), no import bookkeeping, clean diffs, great
for cross-platform setups. **Cons:** convention-only (no guardrails), steeper learning
curve, "magic" auto-import can obscure where settings come from.

**Sources:**
- Dendritic guide (Dendrix) — https://dendrix.denful.dev/Dendritic.html
- DeepWiki (import-tree) — https://deepwiki.com/vic/import-tree/4.4-dendritic-pattern

---

## 6. The "Most Common" Pattern (helper functions + role-based modules)

The de-facto community standard for personal configs (à la Misterio77 / Vimjoyer):

- A plain flake with **helper functions** (`mkDarwin`, `mkHome`) to remove the
  repeated `darwinSystem` / `homeManagerConfiguration` boilerplate.
- Clear separation: `hosts/` (per-machine) + `modules/` (reusable, role-organized)
  + `home/` (user-level).
- `inputs` threaded through via `specialArgs` / `extraSpecialArgs`.

This is the lower-risk, incremental refactor — our existing layout is already ~80%
there; the main win is a DRY `flake.nix`.

---

## 7. Where our current config stands

Already idiomatic: modularized, hosts separated from reusable modules, `inputs.*.follows`
to dedupe, pinned `nixpkgs-unstable`. The main "weirdness" is **boilerplate repetition**
in `flake.nix` (the devenv overlay + near-identical host blocks). Both POC branches
fix that — pick whichever pattern feels right.
