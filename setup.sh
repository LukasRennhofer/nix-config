#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${HOME}"
CONFIG_HOME="${HOME_DIR}/.config"

section() {
  echo
  echo "$1"
}

status_item() {
  echo "  - $1"
}

link_path() {
  local src="$1"
  local dst="$2"

  if [ ! -e "$src" ] && [ ! -L "$src" ]; then
    status_item "Skipping missing source: $src"
    return
  fi

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    status_item "Replacing $dst"
    rm -rf "$dst"
  fi

  mkdir -p "$(dirname "$dst")"
  status_item "Linking $dst"
  ln -s "$src" "$dst"
}

link_config_dir() {
  local name="$1"
  link_path "$REPO_DIR/nixos/$name" "$CONFIG_HOME/$name"
}

section "Dotfiles"
mkdir -p "$CONFIG_HOME"

CONFIG_DIRS=(
  kitty
  i3
  i3blocks
  picom
  rofi
  polybar
  nvim
)

for cfg in "${CONFIG_DIRS[@]}"; do
  link_config_dir "$cfg"
done

section "Wallpapers"
link_path "$REPO_DIR/wallpapers" "$HOME_DIR/.wallpapers"

echo
echo "Done."
