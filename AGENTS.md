# AGENTS.md - Nix-Darwin Configuration Guidelines

## Build/Lint/Test Commands
```bash
darwin-rebuild check --flake .    # Validate configuration without applying
darwin-rebuild switch --flake .   # Apply system configuration changes
nix flake check                   # Check flake configuration
nix-instantiate --parse file.nix  # Check Nix syntax for a single file
```

## Code Style Guidelines
- **File Structure**: Use attribute sets `{ pkgs, lib, ... }:` for module inputs
- **Imports**: Always use relative paths for local modules (e.g., `./modules/shell/zsh.nix`)
- **Formatting**: 2-space indentation, opening braces on same line, closing on new line
- **Comments**: Use `#` for inline, maintain section headers with `# ======` patterns
- **Naming**: Use kebab-case for filenames, camelCase for Nix attributes
- **Module Pattern**: Each module should return an attribute set with relevant config options
- **Dependencies**: Follow inputs with `.follows = "nixpkgs"` to ensure consistency
- **Conditionals**: Use `lib.mkIf`, `lib.mkForce` for overrides, `lib.optional` for lists
- **Error Handling**: Test with `darwin-rebuild check` before applying changes
- **Package Management**: Prefer `home.packages` for user tools, `environment.systemPackages` for system-wide
- **Shell Aliases**: Define in `programs.zsh.shellAliases` using `lib.mkForce` to override defaults