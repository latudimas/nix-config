# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a nix-darwin configuration repository that manages a macOS system configuration using Nix flakes, nix-darwin, and home-manager. The configuration is modularized for maintainability and follows a structured approach to system and user environment management.

## System Management Commands

### Darwin (System) Configuration
```bash
# Apply system configuration changes
darwin-rebuild switch --flake .

# Check configuration without applying
darwin-rebuild check --flake .

# Build configuration without switching
nix build .#darwinConfigurations.smol.system
```

### Home Manager (User) Configuration
```bash
# Apply home manager configuration (usually handled by darwin-rebuild)
home-manager switch --flake .

# Check home manager configuration
home-manager build --flake .
```

### Nix Flake Operations
```bash
# Update flake inputs
nix flake update

# Check flake configuration
nix flake check

# Show flake info
nix flake show
```

## Architecture Overview

### Configuration Structure
- **flake.nix**: Main entry point defining the Darwin configuration "smol" for aarch64-darwin
- **hosts/darwin/**: System-level configuration modules
- **home/dims.nix**: User-specific home-manager configuration entry point
- **modules/**: Modular configuration components organized by function

### Module Organization
- **modules/development/**: Development tools and environments (Node.js, Python, Zig)
- **modules/packages/**: Package collections (CLI tools, Git configuration)
- **modules/shell/**: Shell and terminal configuration (Zsh, Tmux, AI tools, Helix editor)

### Key Configuration Features
- **Zsh with Vi mode**: Custom shell configuration with starship prompt and extensive aliases
- **Git integration**: Pre-configured with GitHub CLI and sensible defaults
- **Direnv support**: Automatic environment loading for project directories
- **Development tools**: Node.js 20 with pnpm, various CLI utilities
- **AI tools**: Claude Code, OpenCode, and Gemini pre-installed

### User Configuration Flow
1. `flake.nix` → `hosts/darwin/default.nix` → `hosts/darwin/system.nix` (system config)
2. `flake.nix` → `home/dims.nix` → imports modules from `modules/` (user config)

### Shell Aliases Available
- **Navigation**: `..`, `...`
- **File operations**: `ls` → `eza`, `cat` → `bat`, `vim` → `nvim`
- **Git shortcuts**: `ga`, `gs`, `gc`, `gco`, `gp`, `gl`, etc.
- **Nix shortcuts**: `nb`, `ns`, `nd`, `nf`
- **Darwin shortcuts**: `drf` (darwin-rebuild switch --flake)

## Development Notes

- System configuration requires `sudo` privileges via `darwin-rebuild`
- Configuration changes should be tested with `darwin-rebuild check` first
- The configuration supports unfree packages (allowUnfree = true)
- Experimental Nix features (flakes, nix-command) are enabled system-wide
- Git is configured with user "latudimas" and email "riswandha.ld@gmail.com"
- Default editor is set to `nvim` for Git operations