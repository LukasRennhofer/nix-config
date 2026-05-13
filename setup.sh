#!/usr/bin/env bash

# nix-config by Lukas Rennhofer (lukas-rennhofer.com)

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

NIXOS_DIR="/etc/nixos"
HOME_DIR="${HOME}"

CONFIG_SOURCE="$REPO_DIR/nixos"
HOME_CONFIG_SOURCE="$REPO_DIR/nixos"

MODE="${1:-setup}"  # default to "setup" if no argument is given

echo "Using repo: $REPO_DIR"
echo "Mode: $MODE"

section () {
  echo
  echo "$1"
}

status_item () {
  echo "  - $1"
}

link_file () {
  local src="$REPO_DIR/$1"
  local dst="$2"

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    status_item "Replacing $dst"
    sudo rm -rf "$dst"
  fi

  status_item "Linking $dst"
  sudo ln -s "$src" "$dst"
}

link_config_dir () {
  local cfg="$1"
  local src="$HOME_CONFIG_SOURCE/$cfg"
  local dst="$HOME_DIR/.config/$cfg"

  if [ -d "$src" ]; then
    if [ -e "$dst" ] || [ -L "$dst" ]; then
      status_item "Replacing $dst"
      rm -rf "$dst"
    fi

    status_item "Linking $dst"
    ln -s "$src" "$dst"
  fi
}

link_home_dir () {
  local name="$1"
  local src="$REPO_DIR/$name"
  local dst="$HOME_DIR/.$name"

  if [ ! -d "$src" ]; then
    echo "Error: $src not found. Aborting." >&2
    exit 1
  fi

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    status_item "Replacing $dst"
    rm -rf "$dst"
  fi

  status_item "Copying $dst"
  cp -r "$src" "$dst"
}

update_symlinks () {
  section "NixOS config"

  # Install `configuration.nix` as a regular file
  if [ -e "$NIXOS_DIR/configuration.nix" ] || [ -L "$NIXOS_DIR/configuration.nix" ]; then
    status_item "Replacing $NIXOS_DIR/configuration.nix"
    sudo rm -rf "$NIXOS_DIR/configuration.nix"
  fi

  # Prefer configuration.nix from repo root. If it's not present, error.
  if [ ! -f "$REPO_DIR/configuration.nix" ]; then
    echo "Error: $REPO_DIR/configuration.nix not found. Aborting." >&2
    exit 1
  fi

  status_item "Writing $NIXOS_DIR/configuration.nix"
  sudo cp "$REPO_DIR/configuration.nix" "$NIXOS_DIR/configuration.nix"

  mkdir -p "$HOME_DIR/.config"

  section "Home config"

  CONFIG_DIRS=(
    kitty
    i3
    i3blocks
    picom
    rofi
    polybar
  )

  for cfg in "${CONFIG_DIRS[@]}"; do
    link_config_dir "$cfg"
  done

  section "Home directories"

  link_home_dir "wallpapers"
}

if [ "$MODE" = "update" ]; then
  update_symlinks
  echo
  echo "Done."
  exit 0
fi

section "Setup"
sudo mkdir -p "$NIXOS_DIR"
update_symlinks

section "Home directories"
XDG_DIRS=(
  Desktop
  Documents
  Music
  Pictures
  Videos
  Templates
  Public
)

status_item "Ensuring: ${XDG_DIRS[*]}"

for dir in "${XDG_DIRS[@]}"; do
  mkdir -p "$HOME_DIR/$dir"
done

status_item "Removing empty defaults"
for dir in "${XDG_DIRS[@]}"; do
  TARGET="$HOME_DIR/$dir"

  if [ -d "$TARGET" ]; then
    if [ -z "$(ls -A "$TARGET" 2>/dev/null)" ]; then
      status_item "Removing $TARGET"
      rmdir "$TARGET"
    fi
  fi
done

echo
echo "Done."
echo "Next: sudo nixos-rebuild switch"
