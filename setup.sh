#!/usr/bin/env bash

# Copyright Lukas Rennhofer (lukas-rennhofer.com)
# My personal NixOS config

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

NIXOS_DIR="/etc/nixos"
HOME_DIR="${HOME}"

CONFIG_SOURCE="$REPO_DIR/nixos"
HOME_CONFIG_SOURCE="$REPO_DIR/nixos"

MODE="${1:-setup}"  # default to "setup" if no argument is given

echo "Using repo: $REPO_DIR"
echo "Mode: $MODE"

link_file () {
  local src="$1"
  local dst="$2"

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    echo "Backing up existing $dst -> ${dst}.bak"
    sudo mv "$dst" "${dst}.bak"
  fi

  echo "Linking $src -> $dst"
  sudo ln -s "$src" "$dst"
}

link_config_dir () {
  local cfg="$1"
  local src="$HOME_CONFIG_SOURCE/.config/$cfg"
  local dst="$HOME_DIR/.config/$cfg"

  if [ -d "$src" ]; then
    if [ -e "$dst" ] || [ -L "$dst" ]; then
      echo "Backing up existing $dst -> ${dst}.bak"
      mv "$dst" "${dst}.bak"
    fi

    echo "Linking $src -> $dst"
    ln -s "$src" "$dst"
  fi
}

update_symlinks () {
  echo "Updating NixOS config symlinks..."

  link_file "configuration.nix" "$NIXOS_DIR/configuration.nix"
  link_file "hardware-configuration.nix" "$NIXOS_DIR/hardware-configuration.nix"

  echo "Updating ~/.config symlinks..."
  mkdir -p "$HOME_DIR/.config"

  CONFIG_DIRS=(
    kitty
    i3
    i3blocks
  )

  for cfg in "${CONFIG_DIRS[@]}"; do
    link_config_dir "$cfg"
  done
}

if [ "$MODE" = "update" ]; then
  update_symlinks
  echo "Update complete."
  exit 0
fi

# -----------------------
# Normal setup mode
# -----------------------

echo "Setting up NixOS configuration symlinks..."
sudo mkdir -p "$NIXOS_DIR"
update_symlinks

echo "Ensuring standard home directories exist..."
XDG_DIRS=(
  Desktop
  Documents
  Music
  Pictures
  Videos
)

for dir in "${XDG_DIRS[@]}"; do
  mkdir -p "$HOME_DIR/$dir"
done

echo "Cleaning up default empty user directories..."
for dir in "${XDG_DIRS[@]}"; do
  TARGET="$HOME_DIR/$dir"

  if [ -d "$TARGET" ]; then
    if [ -z "$(ls -A "$TARGET" 2>/dev/null)" ]; then
      echo "Removing empty directory: $TARGET"
      rmdir "$TARGET"
    else
      echo "Skipping non-empty directory: $TARGET"
    fi
  fi
done

echo "Setup complete."
echo "You may need to run: sudo nixos-rebuild switch"
