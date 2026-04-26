#!/usr/bin/env bash
# One-time setup for Linux machines (WSL / VPS)
# Run this once after cloning the repo on a fresh machine.
# After this, all further config is managed declaratively via home-manager.

# PUBLIC_KEY: dims-nix.cachix.org-1:42IUG0D/t5x5liUzsGzn0UJDfbJ86eO34cJeDkwqLlk=

set -e

CACHIX_CACHE="dims-nix"
CACHIX_URL="https://${CACHIX_CACHE}.cachix.org"
# Get your public key from: https://app.cachix.org/cache/dims-nix
CACHIX_KEY="dims-nix.cachix.org-1:42IUG0D/t5x5liUzsGzn0UJDfbJ86eO34cJeDkwqLlk="

NIX_CONF="/etc/nix/nix.conf"

echo "==> Checking trusted-users..."
if grep -q "trusted-users.*dims" "$NIX_CONF" 2>/dev/null; then
  echo "    dims is already in trusted-users, skipping."
else
  echo "    Adding dims to trusted-users..."
  sudo bash -c "echo 'trusted-users = root dims' >> $NIX_CONF"
  echo "    Done."
fi

echo "==> Checking extra-substituters..."
if grep -q "$CACHIX_URL" "$NIX_CONF" 2>/dev/null; then
  echo "    Cachix substituter already present, skipping."
else
  echo "    Adding Cachix substituter..."
  sudo bash -c "echo 'extra-substituters = $CACHIX_URL' >> $NIX_CONF"
  sudo bash -c "echo 'extra-trusted-public-keys = $CACHIX_KEY' >> $NIX_CONF"
  echo "    Done."
fi

echo "==> Restarting nix-daemon..."
sudo systemctl restart nix-daemon
echo "    Done."

echo ""
echo "Setup complete. You can now run home-manager switch."
echo "Future substituter changes are managed declaratively via nix.settings in home-manager."
