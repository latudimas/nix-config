# Gemini Code-Gen Agent Instructions

This document provides instructions for AI code-generation agents (like Gemini) on how to work with this Nix-based macOS configuration repository.

## Build, Lint, and Test

- **Build & Activate:** To apply the configuration to the system, run:
  ```sh
  darwin-rebuild switch --flake .
  ```
- **Linting:** Format Nix files using `nixpkgs-fmt`:
  ```sh
  nixpkgs-fmt .
  ```
- **Testing:** There is no dedicated test suite. A successful build and activation is the primary test.

## Code Style Guidelines

- **Formatting:** Adhere to the `nixpkgs-fmt` standard.
- **Imports:** Use `import ./path/to/file.nix` for importing local modules.
- **Naming:** Use `camelCase` for variables and attributes, and `kebab-case` for file names.
- **Types:** Nix is dynamically typed; no explicit type annotations are used.
- **Modularity:** Keep configurations modular by splitting them into logical files and directories (e.g., `modules/`, `hosts/`).
- **Error Handling:** Use `lib.mkDefault` and `lib.mkIf` for conditional logic and setting default values to avoid errors.
