# NixOS Migration Options (WSL + VPS)

## WSL: Can We Convert Ubuntu to NixOS-WSL?

**Short answer: No, there is no conversion. It's always a fresh install.**

WSL distributions are self-contained filesystem tarballs. There's no in-place upgrade
path from Ubuntu WSL to NixOS-WSL — they are fundamentally different distributions.
The process is always:

1. Install NixOS-WSL as a new WSL distro alongside (or replacing) Ubuntu:
   ```powershell
   wsl --import NixOS C:\wsl\nixos\ nixos-wsl.tar.gz
   ```
2. Boot into it fresh — no carry-over from Ubuntu

**We already tried NixOS-WSL and found it too buggy.**
The realistic options for `dims-work` are:

| Option | Trade-off |
|---|---|
| Keep Ubuntu + home-manager (current) | Can't declaratively manage system config, one-time manual `/etc/nix/nix.conf` edit needed |
| NixOS-WSL fresh install | Fully declarative, but historically buggy on this setup |

**Current decision: stay on Ubuntu + home-manager standalone.**
The only imperative step needed is the one-time Cachix substituter setup (see CACHIX-LOCAL-SETUP.md).

---

## VPS: nixos-infect vs nixos-anywhere

### nixos-infect

- **Age**: older, around since ~2015
- **Method**: in-place conversion — replaces the running OS while the server is live
- **Risk**: HIGH — if the script fails mid-run, the server can become unreachable with no OS
- **Recovery**: requires VPS provider rescue mode or full reinstall
- **Requirement**: just SSH access, no special provider features needed
- **Rollback**: none

How it works:
```
SSH into Debian VPS
→ run the script
→ script installs Nix, builds NixOS, replaces /etc + bootloader
→ reboots into (hopefully) NixOS
```

### nixos-anywhere

- **Age**: newer, active nix-community project (~2022+)
- **Method**: uses `kexec` to load a minimal NixOS installer into RAM, then does a **clean install**
- **Risk**: LOW — it's a proper fresh install, not in-place surgery on a live OS
- **Recovery**: if it fails, the original OS is usually still intact (kexec loads into RAM)
- **Requirement**: VPS must support `kexec` (most KVM-based providers do; OpenVZ does not)
- **Rollback**: original OS still on disk if kexec stage fails

How it works:
```
Run from your local machine
→ SSHes into VPS, loads NixOS installer into RAM via kexec
→ partitions disk, installs NixOS from your flake
→ reboots into fresh NixOS
```

Command:
```bash
nix run github:nix-community/nixos-anywhere -- --flake .#vps root@<vps-ip>
```

### Side-by-Side Comparison

| | nixos-infect | nixos-anywhere |
|---|---|---|
| Method | In-place conversion | Fresh install via kexec |
| Risk if fails | Server may be unreachable | Usually safe, original OS intact |
| Rollback | None | Original OS on disk |
| Requires kexec | No | Yes |
| Maturity | Older, widely known | Newer, actively maintained |
| Community recommendation | Considered legacy/risky | Preferred for new installs |
| Works on OpenVZ | No | No |
| Works on KVM | Yes | Yes |

### Which to Use

**nixos-anywhere** is the better choice for new NixOS deployments:
- Cleaner install (no leftover Debian files)
- Safer execution model
- Integrates directly with your flake — no manual config after install
- Actively maintained by nix-community

**nixos-infect** only makes sense if your provider doesn't support kexec and you
can't boot a custom ISO.

### Provider kexec Support

| Provider | kexec | Notes |
|---|---|---|
| Hetzner Cloud | Yes | Works well with nixos-anywhere |
| DigitalOcean | Yes | Commonly used |
| Vultr | Yes | Works |
| Linode / Akamai | Yes | Works |
| Oracle Free Tier | Mixed | Arm instances often problematic |
| AWS EC2 | Yes | More complex setup |
| OpenVZ-based | No | Neither tool works |

---

## If We Migrate VPS to NixOS (Future Reference)

The flake changes from:
```nix
homeConfigurations."vps" = home-manager.lib.homeManagerConfiguration {
  pkgs = nixpkgs-stable.legacyPackages."x86_64-linux";
  modules = [ ./hosts/vps ];
};
```

To:
```nix
nixosConfigurations.vps = nixpkgs-stable.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    ./hosts/vps/configuration.nix
    home-manager.nixosModules.home-manager
  ];
};
```

Deploy from local machine:
```bash
nixos-rebuild switch --flake .#vps --target-host root@<vps-ip>
```

This would give the VPS full declarative system config: substituters, system packages,
services, networking — everything in this repo, nothing imperative.
