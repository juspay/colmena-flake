[![project chat](https://img.shields.io/badge/zulip-join_chat-brightgreen.svg)](https://nixos.zulipchat.com/#narrow/stream/413949-haskell-flake)

# colmena-flake

A `flake-parts` module for [colmena](https://github.com/zhaofengli/colmena) deployment tool

## Why

- Re-use an existing `nixosConfigurations`

## How to use

1. Keep your existing NixOS configuration in `nixosConfigurations.<name>` (business as usual)
2. Add your [colmena deployment options](https://colmena.cli.rs/unstable/reference/deployment.html) for any of those configurations, decoupled, under `flake.colmena-flake.deployment.<name>`.
3. Add `pkgs.colmena` to your devShell, and run `colmena apply` to deploy.

## Examples

- [srid/nixos-config](https://github.com/srid/nixos-config/blob/62471af8ca53d7a74b3dd9fabc56d278be0df92d/flake.nix#L49-L63)
