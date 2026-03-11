# Repository Guidelines

## Project Structure & Module Organization
This repository is a flake-based NixOS configuration. Entry points live in `flake.nix` and `flake.lock`. Host definitions are under `hosts/<machine>/default.nix`, with hardware-specific files beside them. Shared system modules live in `system/`, reusable host profiles in `roles/`, desktop presets in `desktop-env/`, package groups in `apps/cli` and `apps/desktop`, and service modules in `services/`. Keep cross-host logic in shared modules and keep host files focused on imports and machine-specific settings.

## Build, Test, and Development Commands
Use flake-aware commands from the repository root:

- `nix flake check --no-build --show-trace`: validate flake evaluation and module wiring.
- `nix build .#nixosConfigurations.nixpad.config.system.build.toplevel`: build a host configuration without switching.
- `sudo nixos-rebuild switch --flake .#nixpad`: apply a host configuration locally.
- `nh os switch .#nixpad`: preferred wrapper if `nh` is installed and configured on the machine.
- `nixpkgs-fmt <file>`: format changed Nix files before committing.

Replace `nixpad` with the target host name, such as `nixarf`, `snootflix`, or `nst-van-checkout`.

## Coding Style & Naming Conventions
Write Nix with two-space indentation and trailing semicolons. Prefer small attribute sets, one import per line when practical, and descriptive kebab-case file names such as `distributed-builds.nix` or `media-storage.nix`. Keep module options and defaults near the top of a file, and use `default.nix` only for directory entry points.

## Testing Guidelines
There is no dedicated unit-test suite in this repo; validation is done through evaluation and host builds. For every change, run `nix flake check --no-build --show-trace` and build at least the affected host output. For service or role changes, test one consuming host explicitly. Treat a successful build as the minimum acceptance bar.

## Commit & Pull Request Guidelines
Recent history uses short, imperative, lowercase commit subjects, for example `fix snootflix build issues` and `add codex to cli apps`. Keep commits focused on one concern. Pull requests should state which hosts or modules are affected, list the validation commands you ran, and include screenshots only for UI-facing desktop changes.

## Security & Configuration Notes
This repo contains `secrets/` data and host metadata. Do not rename, regenerate, or rewrite secret-related files unless the change explicitly requires it. Avoid hardcoding machine-specific paths outside host modules.
