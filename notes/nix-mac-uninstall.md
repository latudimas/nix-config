# Complete Nix Removal & Fresh Start Guide for macOS

## ⚠️ WARNING
This will **permanently delete** all Nix configurations, packages, and data. Proceed with extreme caution.

## Pre-Removal Checklist
- [ ] Backup any important configurations
- [ ] Save any custom derivations or overlays
- [ ] Document any custom shell integrations

## Step 1: Backup Critical Data

```bash
# Backup your current configuration
cp -r ~/.config/nix-darwin ~/nix-darwin-backup-$(date +%Y%m%d)
cp -r ~/.nix-profile ~/nix-profile-backup-$(date +%Y%m%d)

# Backup any custom configurations
cp -r ~/.config/home-manager ~/.config/home-manager-backup-$(date +%Y%m%d)
```

## Step 2: Remove Nix-Darwin Configuration

```bash
# Remove nix-darwin configuration
sudo rm -rf /etc/nix-darwin
sudo rm -rf /run/current-system
```

## Step 3: Uninstall Nix Package Manager

```bash
# Stop all Nix services
sudo launchctl unload /Library/LaunchDaemons/org.nixos.nix-daemon.plist 2>/dev/null || true
sudo launchctl unload /Library/LaunchDaemons/org.nixos.darwin-store.plist 2>/dev/null || true

# Remove Nix daemon
sudo rm -f /Library/LaunchDaemons/org.nixos.nix-daemon.plist
sudo rm -f /Library/LaunchDaemons/org.nixos.darwin-store.plist

# Remove Nix store and binaries
sudo rm -rf /nix
sudo rm -rf /var/root/.nix-profile
sudo rm -rf /var/root/.nix-defexpr
sudo rm -rf /var/root/.nix-channels

# Remove user Nix data
rm -rf ~/.nix-profile
rm -rf ~/.nix-defexpr
rm -rf ~/.nix-channels
rm -rf ~/.cache/nix
rm -rf ~/.local/share/nix
rm -rf ~/.config/nix
```

## Step 4: Remove Shell Integration

```bash
# Remove Nix from shell profiles
sed -i '' '/nix-darwin/d' ~/.zshrc
sed -i '' '/nix-darwin/d' ~/.bashrc
sed -i '' '/nix.sh/d' ~/.zshrc
sed -i '' '/nix.sh/d' ~/.bashrc

# Remove Nix PATH entries
sudo sed -i '' '/nix/d' /etc/zshrc 2>/dev/null || true
sudo sed -i '' '/nix/d' /etc/bashrc 2>/dev/null || true
```

## Step 5: Clean Up LaunchDaemons & LaunchAgents

```bash
# Remove any remaining Nix services
sudo rm -f /Library/LaunchDaemons/org.nixos.*
sudo rm -f ~/Library/LaunchAgents/org.nixos.*
```

## Step 6: Verify Complete Removal

```bash
# Check if Nix is completely removed
echo "Checking Nix removal..."
echo "which nix: $(which nix 2>/dev/null || echo 'NOT FOUND')"
echo "/nix directory: $(ls -la /nix 2>/dev/null || echo 'NOT FOUND')"
echo "NIX_PATH: ${NIX_PATH:-NOT SET}"

# Check for any remaining Nix processes
ps aux | grep -i nix || echo "No Nix processes found"
```

## Step 7: Reboot System

```bash
sudo reboot
```

## Step 8: Fresh Nix Installation

After reboot, install Nix fresh:

```bash
# Install Nix (multi-user)
sh <(curl -L https://nixos.org/nix/install) --daemon

# Source nix environment
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# Install nix-darwin
nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
./result/bin/darwin-installer

# Clone fresh configuration (if you have a repo)
git clone <your-repo-url> ~/.config/nix-darwin
cd ~/.config/nix-darwin

# Update to use 25.05
# Edit flake.nix to use:
# home-manager.url = "github:nix-community/home-manager/release-25.05";
# In home.nix, set:
# home.stateVersion = "25.05";

# Apply fresh configuration
darwin-rebuild switch --flake .
```

## Verification Commands

```bash
# Verify clean installation
nix --version
home-manager --version
darwin-rebuild --help

# Check state version
grep "stateVersion" ~/.config/nix-darwin/home/dims.nix
```

## Troubleshooting

### If Nix commands still work after removal:
```bash
# Check for remaining Nix installations
which -a nix
ls -la /usr/local/bin/nix* 2>/dev/null || true
ls -la /opt/nix 2>/dev/null || true
```

### If you get permission errors:
```bash
# Force remove any remaining files
sudo rm -rf /nix
sudo rm -rf /etc/nix
sudo rm -rf /var/root/.nix-*
```

### If shell integration persists:
```bash
# Check all shell config files
grep -r "nix" ~/.zshrc ~/.bashrc ~/.profile ~/.bash_profile 2>/dev/null || true
```

## Post-Installation Notes

After fresh installation:
- Your new `stateVersion` will be "25.05"
- All packages will be re-downloaded
- Configuration will be completely fresh
- No migration from old setup will occur

## Emergency Rollback

If you need to restore your old configuration:
```bash
# Restore from backup
cp -r ~/nix-darwin-backup-*/ ~/.config/nix-darwin/
cd ~/.config/nix-darwin
darwin-rebuild switch --flake .
```