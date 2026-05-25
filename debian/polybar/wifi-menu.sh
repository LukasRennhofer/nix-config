#!/usr/bin/env bash
set -euo pipefail

menu() {
  if command -v rofi >/dev/null 2>&1; then
    rofi -dmenu -i -p "$1"
  else
    dmenu -i -p "$1"
  fi
}

password_prompt() {
  if command -v rofi >/dev/null 2>&1; then
    rofi -dmenu -password -i -p "$1"
  else
    printf 'Rofi is required for password entry in this setup.\n' >&2
    exit 1
  fi
}

wifi_iface() {
  nmcli -t -f DEVICE,TYPE dev status | awk -F: '$2 == "wifi" { print $1; exit }'
}

current_ssid() {
  nmcli -t -f active,ssid dev wifi | awk -F: '$1 == "yes" { print $2; exit }'
}

show_status() {
  local ssid
  ssid="$(current_ssid || true)"
  if [[ -n "${ssid:-}" ]]; then
    printf '󰖩 %s\n' "$ssid"
  else
    printf '󰖪 off\n'
  fi
}

connect_wifi() {
  local iface choice ssid security password
  iface="$(wifi_iface)"

  if [[ -z "${iface:-}" ]]; then
    printf 'No WiFi interface found\n' >&2
    exit 1
  fi

  choice="$({
    nmcli -t -f SSID,SECURITY,SIGNAL dev wifi list ifname "$iface" --rescan yes |
      awk -F: 'NF >= 3 && $1 != "" { printf "%s | %s%% | %s\n", $1, $3, $2 }'
  } | menu 'WiFi')"

  [[ -z "${choice:-}" ]] && exit 0

  ssid="${choice%% | *}"
  security="${choice##* | }"

  if [[ "$security" != "--" && "$security" != "" ]]; then
    password="$(password_prompt 'Password')"
  else
    password=""
  fi

  if [[ -n "${password:-}" ]]; then
    nmcli --wait 10 dev wifi connect "$ssid" ifname "$iface" password "$password"
  else
    nmcli --wait 10 dev wifi connect "$ssid" ifname "$iface"
  fi
}

case "${1:-status}" in
  status)
    show_status
    ;;
  connect)
    connect_wifi
    ;;
  toggle)
    nmcli radio wifi toggle
    ;;
  *)
    show_status
    ;;
esac
