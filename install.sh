#!/bin/bash
set -euo pipefail

echo "[*] Installing prerequisites..."
sudo apt update
sudo apt install -y nmap arp-scan nbtscan avahi-utils dnsmasq

echo "[*] Disabling systemd-resolved (Ubuntu default DNS resolver)..."
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved

echo "[*] Enabling and starting dnsmasq..."
sudo systemctl enable dnsmasq
sudo systemctl start dnsmasq

# Add line to dnsmasq.conf if not already present
CONF_LINE="addn-hosts=/etc/hosts.generated"
if ! grep -Fxq "$CONF_LINE" /etc/dnsmasq.conf; then
  echo "$CONF_LINE" | sudo tee -a /etc/dnsmasq.conf > /dev/null
  echo "[*] Updated /etc/dnsmasq.conf with addn-hosts."
else
  echo "[*] /etc/dnsmasq.conf already contains addn-hosts."
fi

echo "[*] Setting up cron job to update /etc/hosts.generated every 10 minutes..."
CRON_CMD="*/10 * * * * cd $(pwd) && sudo ./generate-hosts-file.sh > /dev/null 2>&1"
( crontab -l 2>/dev/null; echo "$CRON_CMD" ) | crontab -

echo "[✓] Installation complete. Run ./generate-hosts-file.sh manually to test."
