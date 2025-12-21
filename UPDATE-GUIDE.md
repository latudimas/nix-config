# Nix Flake Update Guide

This guide explains how to update packages and flake inputs in this nix-darwin configuration.

## Understanding Flake Inputs

This configuration has three main inputs defined in `flake.nix` and locked in `flake.lock`:

- **nixpkgs**: The Nix package repository (currently tracking `nixpkgs-unstable`)
- **home-manager**: Manages user environment and dotfiles
- **nix-darwin**: Manages macOS system configuration

The `flake.lock` file pins these inputs to specific commits, ensuring reproducible builds.

## Update Options

### Option 1: Update All Inputs (Recommended for Regular Updates)

**Commands to run:**
```bash
nix flake update
```

Then after it completes:
```bash
darwin-rebuild switch --flake .
```

After it's done, verify the version:
```bash
claude-code --version
```

**What it does:**
- Updates ALL flake inputs (nixpkgs, home-manager, nix-darwin) to their latest versions
- Modifies `flake.lock` with new commit hashes
- Applies the updated configuration to your system

**When to use:**
- Regular maintenance updates
- When you're only a few days/weeks behind
- When you want all bug fixes and improvements across the stack

**Pros:**
- Simplest approach
- Keeps everything in sync
- Gets you all latest features and fixes

**Cons:**
- Higher chance of breaking changes (but can rollback easily)
- Updates more than you might need

### Option 2: Update Single Input (Targeted Updates)

```bash
# Update only nixpkgs
nix flake lock --update-input nixpkgs
darwin-rebuild switch --flake .

# Update only home-manager
nix flake lock --update-input home-manager
darwin-rebuild switch --flake .

# Update only nix-darwin
nix flake lock --update-input nix-darwin
darwin-rebuild switch --flake .
```

**What it does:**
- Updates ONLY the specified input
- Leaves other inputs at their current locked versions
- More surgical approach to updates

**When to use:**
- When you need a specific package update from nixpkgs
- When one input has known breaking changes you want to avoid
- For debugging which input caused an issue
- When you want to minimize changes

**Pros:**
- More control over what changes
- Lower risk of breakage
- Easier to identify source of problems

**Cons:**
- Requires more knowledge of which input to update
- May miss related fixes in other inputs

### Option 3: Check Available Versions First

```bash
# Check what version of a package is available
nix search nixpkgs#claude-code --json | jq '.[].version'

# Or just show package info
nix search nixpkgs#claude-code
```

**What it does:**
- Queries the current nixpkgs (without updating) for package versions
- Useful for verification before updating

**When to use:**
- Before updating, to see if the version you want is available
- To verify package names and availability

## Common Update Workflows

### Regular Maintenance (Weekly/Monthly)

```bash
# Update everything
nix flake update

# Check what will change (optional)
nix flake check

# Apply changes
darwin-rebuild switch --flake .
```

### Updating a Specific Package

```bash
# If the package is from nixpkgs
nix flake lock --update-input nixpkgs
darwin-rebuild switch --flake .
```

### Safe Update with Verification

```bash
# Update flake
nix flake update

# Build without switching (test first)
darwin-rebuild build --flake .

# If successful, switch
darwin-rebuild switch --flake .
```

## Rollback if Something Breaks

Nix makes rollback easy:

```bash
# Rollback to previous generation
darwin-rebuild --rollback

# Or list generations and switch to specific one
darwin-rebuild --list-generations
darwin-rebuild --switch-generation <number>
```

You can also rollback just the flake.lock:

```bash
git checkout flake.lock
darwin-rebuild switch --flake .
```

## Checking Your Current Versions

```bash
# Show flake inputs and their current commits
nix flake metadata

# Show what changed in last update
git diff HEAD~1 flake.lock

# Check installed package version
nix-env -qa claude-code
# or
claude-code --version
```

## Example: Updating claude-code from 2.0.17 to 2.0.55

Since claude-code comes from nixpkgs:

```bash
# Option 1: Update everything (recommended if you're only days behind)
nix flake update
darwin-rebuild switch --flake .

# Option 2: Update only nixpkgs (if you want to be conservative)
nix flake lock --update-input nixpkgs
darwin-rebuild switch --flake .

# Verify new version
claude-code --version
```

## Best Practices

1. **Commit before updating**: Always commit your current state before updating
   ```bash
   git add flake.lock
   git commit -m "Lock file before update"
   ```

2. **Review changes**: Check what changed in flake.lock
   ```bash
   git diff flake.lock
   ```

3. **Test before committing**: Make sure everything works before committing the update

4. **Stay relatively current**: If on unstable, update regularly (weekly/monthly) to avoid large jumps

5. **Use version control**: Git makes rollback easy if updates break things

## Troubleshooting

### Update fails with "error: unable to download"
- Check internet connection
- The upstream repository might be temporarily unavailable
- Try again later

### Build fails after update
- Check the error message for which package/module failed
- Search NixOS discourse or GitHub issues for the error
- Rollback and wait for fixes: `darwin-rebuild --rollback`

### Package version didn't change after update
- The package might already be at the latest version in unstable
- Check when nixpkgs was last updated: `nix flake metadata`
- The package might not have been updated in nixpkgs yet

### Home-manager or nix-darwin breaking changes
- Check their respective changelogs
- Look for deprecation warnings in build output
- Update your configuration accordingly
