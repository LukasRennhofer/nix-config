# Debian Configuration

My *newer* personal dotfiles for Debian. Yes Debian, because Arch is avoiding NVIDIA, but I need a CUDA and OPTIX chain. NixOS wasnt the best too, because it still has NO support for that, so I chose the grandfather distros.

## Dotfiles

It just includes my terminal and i3 configurations, because I dont like that much custom themes.

## Setup

Just run `./setup.sh` for setting everything up and `./setup.sh update` for updating the dotfile symlinks. Existing destination paths are removed and replaced with symlinks.