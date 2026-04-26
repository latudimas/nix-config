# Nix Garbage Collection Guide

## What is Garbage Collection?

Nix stores all packages immutably in `/nix/store/`. Over time, old package versions and unused dependencies accumulate, consuming disk space. **Garbage collection** (GC) is the process of removing these unreferenced store paths.

## Key Terminology

| Term | Definition |
|------|------------|
| **Store path** | Immutable package location in `/nix/store/` |
| **Generation** | Snapshot of your system/home configuration at a point in time |
| **GC root** | Reference that prevents a store path from being garbage collected |
| **Garbage** | Unreferenced store paths eligible for deletion |

## Basic Commands

### Standard Garbage Collection
```bash
# Delete unreferenced store paths
nix-collect-garbage

# Delete old generations AND garbage (recommended)
nix-collect-garbage -d

# System-wide cleanup (requires sudo)
sudo nix-collect-garbage -d
```

### Time-based Cleanup
```bash
# Delete generations older than 7 days
nix-collect-garbage --delete-older-than 7d

# Delete generations older than 30 days
nix-collect-garbage --delete-older-than 30d
```

### Inspection Commands
```bash
# List what would be deleted (dry run)
nix-store --gc --print-dead

# Check store disk usage
du -sh /nix/store

# Optimize store by deduplicating files
nix-store --optimise
```

## Darwin-Specific Commands

### Managing nix-darwin Generations
```bash
# List all system generations
darwin-rebuild --list-generations

# Delete specific generation (e.g., generation 5)
nix-env --delete-generations 5 --profile /nix/var/nix/profiles/system

# Delete all old generations except current
nix-env --delete-generations old --profile /nix/var/nix/profiles/system
```

## Home Manager Commands

```bash
# List home-manager generations
home-manager generations

# Remove generations older than 7 days
home-manager expire-generations "-7 days"
```

## Recommended Cleanup Routine

### Quick Full Cleanup
```bash
# Remove old generations + garbage + optimize store
sudo nix-collect-garbage -d && nix-store --optimise
```

### Weekly Maintenance
```bash
# Keep last 7 days of generations
nix-collect-garbage --delete-older-than 7d
home-manager expire-generations "-7 days"
nix-store --optimise
```

### Monthly Deep Clean
```bash
# Remove all old generations
sudo nix-collect-garbage -d
home-manager expire-generations "-30 days"
nix-store --optimise
```

## How Garbage Collection Works

1. **GC roots** are identified (current generation, profiles, user environments)
2. Nix traces all dependencies from GC roots
3. Store paths not reachable from any GC root are marked as garbage
4. Garbage is deleted from `/nix/store/`

## Safety Notes

- Garbage collection is safe - only unreferenced paths are deleted
- You can always rebuild from your configuration
- Old generations allow rollback - keep at least one recent generation
- Use `--delete-older-than` instead of `-d` if you want rollback safety

## Space Savings

Typical space savings:
- First GC after months: 10-50GB
- Regular weekly GC: 1-5GB
- Store optimization: 5-20% additional savings

## Troubleshooting

**Issue**: "Permission denied" errors
**Solution**: Use `sudo nix-collect-garbage -d`

**Issue**: Minimal space freed
**Solution**: Old generations may be keeping packages alive. Delete them first.

**Issue**: Need to rollback after GC
**Solution**: If you deleted generations with `-d`, you cannot rollback. Rebuild from config instead.
