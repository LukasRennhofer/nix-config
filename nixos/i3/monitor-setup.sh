#!/usr/bin/env bash
set -eu
# Detect an HDMI output and the built-in panel (eDP/LVDS). If HDMI is connected,
# set it as primary and put the laptop panel to its right.

XRANDR_OUT=$(xrandr --query)

# Find first connected HDMI/DP-like output (match names starting with HDMI, DP- or DisplayPort).
# Use field checks so we don't accidentally match "eDP" (which contains "DP").
HDMI_OUT=$(awk '$1 ~ /^(HDMI|DP-|DisplayPort)/ && $2 == "connected" {print $1; exit}' <<< "$XRANDR_OUT" || true)

# Find built-in panel (match names starting with eDP or LVDS)
INTERNAL_OUT=$(awk '$1 ~ /^(eDP|LVDS)/ && $2 == "connected" {print $1; exit}' <<< "$XRANDR_OUT" || true)

if [ -n "$HDMI_OUT" ]; then
  if [ -n "$INTERNAL_OUT" ]; then
    # HDMI connected + internal display — make HDMI primary and put internal to the right
    xrandr --output "$HDMI_OUT" --primary --auto --output "$INTERNAL_OUT" --auto --right-of "$HDMI_OUT"
  else
    # Only HDMI connected
    xrandr --output "$HDMI_OUT" --primary --auto
  fi
fi

exit 0