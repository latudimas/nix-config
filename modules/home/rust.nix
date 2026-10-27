# Aspect: Rust toolchain. Only turned on for smol (see modules/hosts.nix).
# Ships rustup rather than a fixed rustc/cargo so toolchains (stable, nightly,
# extra targets) and per-project rust-toolchain.toml pins work as usual.
# First run after switching: `rustup default stable`.
{
  flake.modules.homeManager.rust =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        rustup # manages rustc/cargo/clippy/rustfmt/rust-analyzer per toolchain
      ];

      # Keep rustup/cargo state under ~/.local/share instead of ~/.rustup, ~/.cargo.
      home.sessionVariables = {
        RUSTUP_HOME = "$HOME/.local/share/rustup";
        CARGO_HOME = "$HOME/.local/share/cargo";
      };
      # `cargo install`ed binaries.
      home.sessionPath = [ "$HOME/.local/share/cargo/bin" ];
    };
}
