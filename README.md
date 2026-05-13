# NixOS Configuration

My personal dotfiles and system configuration of my NixOS machines. This includes my two laptops, which are now entirely powered by Nix.

## Dotfiles

It just includes my terminal and i3 configurations, because I dont like that much custom themes.

## Setup

Just run `./setup.sh` for setting everything up and `./setup.sh update` for updating the dotfile symlinks. Existing destination paths are removed and replaced with symlinks.

`hardware-configuration.nix` stays in the repo and is not symlinked by the setup script.
